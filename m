From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen patch available for perusal.
Date: Sat, 04 Nov 2006 11:12:21 -0800
Message-ID: <454CE615.20208@candelatech.com>
References: <45468F2E.4060809@candelatech.com>	 <17736.54766.657083.873206@robur.slu.se> <4548F166.1020001@candelatech.com>	 <1162643532.5166.34.camel@jzny2>  <454CCDE0.5040109@candelatech.com> <1162663855.6237.116.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:20910 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1753629AbWKDTLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Nov 2006 14:11:02 -0500
To: hadi@cyberus.ca
In-Reply-To: <1162663855.6237.116.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sat, 2006-04-11 at 09:29 -0800, Ben Greear wrote:
>   

> You can ofcourse add many of these based on other header info.
>
> It seems to me your magic header is inside the UDP packet, correct?
> In that case you will have to play with matches since you can specify
> arbitraty offsets and values inside the packet.
>   
Yes, I want to be able to randomize source/dest MAC, IP, and IP Port, so 
I need to match only on the
magic cookie.  I'll soon add support to deal with TCP packets as well, 
but that is only going to require
calculating a different offset to look for the magic value.
> Of course you can do this from your application instead of using tc.
> I think that will be the best place to control this and sync with
> pktgen sending.
>   
You mean the equiv of calling system(tc filter .....) from the app, or 
do you mean something else
entirely?
>> the rest can be in a method 
>> called after you match in your script?
>>
>>     
>
> If the packet/byte counters that the drop action provides are not good
> enough, you can write yourself a little module that will do the
> accounting the way you want it. For example this will be necessary to
> the out-of-sequence cheques below. Timestamps are already being updated
> Look at net/sched/act_simple.c and its associated user space code in
> iproute2.
>
> Now, Ben - are you listening really this time or am i wasting my time
> for the nth time giving you all these details? ;->
>   
You always give details that are pertinent to your setup and not to 
mine, and you
always have some 'small' step that is 'write a kernel module and hack on 
tc' if you
want it to do something other than the generic thing.
> If you are listening then start with:
>
> 1) Do a simple test with just udp traffic as above, doing simple
> accounting. This helps you to get a feel on how things work.
> 2) modify the matching rules to match your magic cookie
>   
These first two do not look too difficult.  I certainly need more 
control/stats than
what the generic counters would be, however, so I assume I need to move 
to step 3.
> 3) write a simple action invoked by your matching rules and use tc to
> add it to the policy.
>   
I have exactly no idea of what you mean by this.  How do I get this tc 
framework to
send the packet with 32-bit value FOO at offset X to some method called 
pktgen_rx_pkt(skb)
in the pktgen module?  That is all I want in a hook:  The ability to 
match on a pkt and send it
to my kernel module and to let my kernel module and have it traverse the 
stack no farther
unless my kernel module decides to re-insert it for some reason.

If this takes significant work, then please don't waste more time trying 
to talk me
into this, as my small patch to dev.c already does exactly what I need 
and the code
is very easy to understand.

If this is easy, how about you write the module and make the tc 
changes.  I'll work on any
changes needed in pktgen and polish up a nice patch for Robert et 
al....  Then you can get
the latency distributions, OOO, Dup, Dropped and other counters that my 
pktgen logic
provides for your own testing purposes...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



From: Yan-Fa Li <yan@intruvert.com>
Subject: RE: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 13:12:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <D71BEAC27500D51199DF0002B328BA8D4FBD7B@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cacophonix <cacophonix@yahoo.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Ben Greear'" <greearb@candelatech.com>,
   Chris Friesen
	 <cfriesen@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I had similar problems with NAPI and DL2K.  I was only able to "resolve" the
issue by forcing my application and the NIC to a single CPU using CPU
affinity
hacks.

-----Original Message-----
From: Ben Greear [mailto:greearb@candelatech.com] 
Sent: Monday, September 16, 2002 9:10 AM
To: Chris Friesen
Cc: Cacophonix; linux-net@vger.kernel.org; netdev@oss.sgi.com
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation


Chris Friesen wrote:
> Cacophonix wrote:
> 
>>--- Chris Friesen <cfriesen@nortelnetworks.com> wrote:
> 
> 
>>>This has always confused me.  Why doesn't the bonding driver try and 
>>>spread all the traffic over all the links?
>>
>>Because then you risk heavy packet reordering within an individual 
>>flow, which can be detrimental in some cases. --karthik
> 
> 
> I can see how it could make the receiving host work more on 
> reassembly, but if throughput is key, wouldn't you still end up better 
> if you can push twice as many packets through the pipe?
> 
> Chris

Also, I notice lots of out-of-order packets on a single gigE link when
running at high speeds (SMP machine), so the kernel is still having to
reorder quite a few packets. Has anyone done any tests to see how much worse
it is with dual-port bonding?

NAPI helps my problem, but does not make it go away entirely.

Ben

> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

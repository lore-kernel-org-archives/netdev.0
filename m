From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 00/10] Implement batching skb API
Date: Mon, 23 Jul 2007 08:32:01 -0400
Message-ID: <1185193921.26013.37.camel@localhost>
References: <OFFA8C2879.1D54F523-ON65257321.0010F240-65257321.001A8A31@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.251]:27353 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbXGWMcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 08:32:07 -0400
Received: by ag-out-0708.google.com with SMTP id 35so1549274aga
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 05:32:06 -0700 (PDT)
In-Reply-To: <OFFA8C2879.1D54F523-ON65257321.0010F240-65257321.001A8A31@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KK,

On Mon, 2007-23-07 at 10:19 +0530, Krishna Kumar2 wrote:

> Hmmm ? Evgeniy has not even tested my code to find some regression :) And
> you may possibly not find much improvement in E1000 when you run iperf
> (which is what I do) compared to pktgen. 

Pktgen is the correct test (or the closest to correct) because it tests
the driver tx path. iperf/netperf test the effect of batching on
tcp/udp. Infact i would start with udp first. What you need to do if
testing end-2-end is see where the effects occur. For example, it is
feasible that batching is a little too aggressive and the receiver cant
keep up (netstat -s before and after will be helpful).
Maybe by such insight we can improve things.

> > My experiments show it is useful (in a very visible way using pktgen)
> > for e1000 to have the prep() interface.
> 
> I meant : have you compared results of batching with prep on vs prep off,
> and
> what is the difference in BW ?

Yes, and these results were sent to you as well a while back.
When i get the time when i get back i will look em up in my test machine
and resend.

> No. I see value only in non-LLTX drivers which also gets the same TX lock
> in the RX path.

So _which_ non-LLTX driver doesnt do that? ;->

> > The value is also there in LLTX drivers even if in just formating a skb
> > ready for transmit. If this is not clear i could do a much longer
> > writeup on my thought evolution towards adding prep().
> 
> In LLTX drivers, the driver does the 'prep' without holding the tx_lock in
> any case, so there should be no improvement. Could you send the write-up

I will - please give me sometime; i am overloaded at the moment.

> There is *nothing* IPoIB specific or focus in my code. 
> I said adding prep
> doesn't
> work for IPoIB and so it is pointless to add bloat to the code until some
> code can

tun driver doesnt use it either - but i doubt that makes it "bloat"

>  What I meant to say
> is that there isn't much point in saying that your code is not ready or
> you are using old code base, or has multiple restart functions, or is not
> tested enough, etc, and then say let's re-do/rethink the whole
> implementation when my code is already working and giving good results.

The suggestive hand gesturing is the kind of thing that bothers me. What
do you think: Would i be submitting patches in baed on 2.6.22-rc4? Would
it make sense to include parallel qdisc paths? For heavens sake, i have
told you i would be fine with accepting such changes when the qdisc
restart changes went in first.
You waltz in, have the luxury of looking at my code, presentations, many
discussions with me etc ...
When i ask for differences to code you produced, they now seem to sum up
to the two below. You dont think theres some honest issue with this
picture?

> OTOH, if you find some cases that are better handled with :
>       1. prep handler
>       2. xmit_win (which I don't have now),
> then please send me patches and I will also test out and incorporate.
> 

And then of course you will end up adding those because they are both
useful, just calling them some other name. And then you will end up
incorporating all the drivers i invested many hours (as a gratitous
volunteer) to change and test - maybe you will change varibale names or
rearrange some function. 
I am a very compromising person; i have no problem coauthoring these
patches if you actually invest useful time like fixing things up and
doing proper tests. But you are not doing that - instead you are being
extremely aggressive and hijacking the whole thing. It is courteous if
you find somebody else has a patch you point out whats wrong preferably
with some proof. 

> > It sounds disingenuous but i may have misread you.
> 
> ("lacking in frankness, candor, or sincerity; falsely or hypocritically
> ingenuous; insincere") ???? Sorry, no response to personal comments and
> have a flame-war :)

Give me a better description. 

cheers,
jamal


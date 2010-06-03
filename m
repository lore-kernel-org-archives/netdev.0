From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 03 Jun 2010 08:43:50 -0400
Message-ID: <1275569030.3445.49.camel@bigi>
References: <1274781067.3878.872.camel@bigi>
	 <20100525102603.GA11494@gondor.apana.org.au>
	 <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
	 <1274790038.3878.926.camel@bigi>
	 <20100525124636.GA13161@gondor.apana.org.au>
	 <1274793216.3878.947.camel@bigi>
	 <20100525231307.GA19475@gondor.apana.org.au>
	 <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi>
	 <20100603080130.GA29709@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.211.179]:48533 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab0FCMn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 08:43:57 -0400
Received: by ywh9 with SMTP id 9so63683ywh.17
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 05:43:54 -0700 (PDT)
In-Reply-To: <20100603080130.GA29709@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2010-06-03 at 18:01 +1000, Herbert Xu wrote:
> On Sun, May 30, 2010 at 09:29:10AM -0400, jamal wrote:

> > The packet path is:
> > -->eth0-->tcpdump eth0-->pedit-->mirror to dummy0-->tcpdump dummy0
> 
> Well this doesn't guarantee a cloned packet at all.  Once af_packet
> receives the packet it'll wake up any listeners like tcpdump, if
> tcpdump gets to it before pedit runs then the packet won't be
> cloned anymore.

I may be misreading, but:
This is the point i have been trying to make, Herbert;-> There is no
_guarantee_ that the first tcpdump will see the packet that came out of
eth0 instead of seeing the packet that came out the pedit part of the
pipeline. I need to see the correct packet. I know with my check
this is guaranteed.

> Anyway, I don't see why actions are special.  Everybody else lives
> by the rule that cloned skbs are not writeable.  

Yes, if skb_cloned() is true but it is not as i said in my earlier
email.

> So if this was
> indeed buggy as you say it would have shown up a long time ago.

Things may have been buggy - I dont know; you just validated to me that
it _may_ happen. I will be more than happy to remove it if i can get a
guarantee.
So how do we fix this?
Does af_packet need to always clone? That way i can depend on it. I have
a feeling someone will be unhappy with that. I am avoiding to clone
every packet on my part because afaik this problem doesnt exist if i
dont use tcpdump/af_packet...

> Case in point, we had a bug in certain NIC drivers where they
> modified cloned skbs for TSO.  This quickly showed up as bogus
> packets in tcpdump and we fixed it.

I think this is different.

cheers,
jamal


From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Wed, 18 Nov 2015 10:35:12 -0800
Message-ID: <1447871712.22599.175.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
	 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151118153621.GA5860@breakpoint.cc>
	 <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447862057.909111.443349025.5B7D067D@webmail.messagingengine.com>
	 <1447867736.22599.169.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447868159.400039.443456489.4AB3FECE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34803 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbbKRSfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 13:35:15 -0500
Received: by padhx2 with SMTP id hx2so52590517pad.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 10:35:15 -0800 (PST)
In-Reply-To: <1447868159.400039.443456489.4AB3FECE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 18:35 +0100, Hannes Frederic Sowa wrote:
> On Wed, Nov 18, 2015, at 18:28, Eric Dumazet wrote:
> > On Wed, 2015-11-18 at 16:54 +0100, Hannes Frederic Sowa wrote:
> > 
> > > Still, the RST packet can be dropped along the way. So the teardown of
> > > the socket on the other side might not happen.
> > 
> > This is why it is better to send RST for every incoming in-excess packet
> 
> I agree it would be better to send a RST than ACK incoming data. Just
> thinking out loud, would it make sense to add a sub-state to timewait so
> we RST all other packets for TIMEWAIT_LEN duration?

Intuitively this timewait creation looks dangerous to me, maybe from
an attack surface perspective.

An out of sequence packet sends an advisory RST packet, which is already
a hint for building some kinds of attacks.

Now if we also create a timewait socket, and its associated timer, we
also add quite a risk of memory and cpu consumption.

So I am fine you create a timewait, only if you can prove there is no
change in security.

Thanks !

From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/2] LSM: Add inet_sys_snd_skb() LSM hook
Date: Fri, 4 Jan 2008 09:38:27 -0500
Message-ID: <200801040938.27515.paul.moore@hp.com>
References: <20080103171649.14445.65274.stgit@flek.americas.hpqcorp.net> <20080103172539.14445.1668.stgit@flek.americas.hpqcorp.net> <20080103.204549.204229388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:45363 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbYADOim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 09:38:42 -0500
In-Reply-To: <20080103.204549.204229388.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 11:45:49 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Thu, 03 Jan 2008 12:25:39 -0500
>
> > Add an inet_sys_snd_skb() LSM hook to allow the LSM to provide
> > packet level access control for all outbound packets.  Using the
> > existing postroute_last netfilter hook turns out to be problematic
> > as it is can be invoked multiple times for a single packet, e.g.
> > individual IPsec transforms, adding unwanted overhead and
> > complicating the security policy.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> I disagree with this change.
>
> The packet is different each time you see it in the postrouting hook,
> and also the new hook is thus redundant.

Well, thanks for taking a look.

> If it's a performance issue and you can classify the security early,
> mark the SKB as "seen" and then on subsequent hooks you can just
> return immediately if that flag is set.

Unfortunately, it's not quite that easy at present.  The only field we 
have in the skb where we could possibly set a flag is the secmark field 
which is already taken.  Granted, there is the possibility of 
segmenting the secmark field to some degree but that brings about a new 
set of problems involving the number of unique labels, backwards 
compatibility, etc.

Regardless, back to the drawing board.  I'll have to think a bit harder 
about a way to make the netfilter hooks work ...

-- 
paul moore
linux security @ hp

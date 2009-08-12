From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v8)
Date: Wed, 12 Aug 2009 15:19:49 -0400
Message-ID: <4A8315D5.4030007@librato.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com>	<1249918379-29414-6-git-send-email-danms@us.ibm.com>	<4A82DFE0.4040108@librato.com> <873a7x59ji.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.iad.emailsrvr.com ([207.97.245.191]:50166 "EHLO
	smtp191.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbZHLTTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 15:19:50 -0400
In-Reply-To: <873a7x59ji.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> Before pulling this one, I took a quick look at this patch, and I
> OL> saw that it still uses skb_morph despite the changelog and my
> OL> memory...
> 
> That's correct.  We've been through several ways of allocating the
> skb's, so it's definitely confusing.  We're back to skb_morph()
> because I'm pre-allocating them for lock safety when traversing the
> queues.  The only thing that is allocated is the actual skb structure
> itself; the buffers are still shared like with skb_clone().
> 
> OL> 1) Move 'struct ckpt_hdr_socket' et-al to checkpoint_hdr.h
> 
> Okay, yeah, I guess we never really resolved the question of where
> they really belong, but I'll put them back there for now.
> 
> OL> 2) Move everything that is af_unix specific from net/checkpoint.c
> OL> to (a new) net/unix/checkpoint.c (prototypes probably in af_unix.h
> OL> ?)
> 
> Um, I guess I can.  That will end up with a bunch of other
> externally-defined interfaces between the generic and the specific
> code, but I suppose I don't really have a solid argument against it.
> 
> OL> 3) Make sure that af_unix code does not compile (and is not called
> OL> from net/checkpoint.c) unless CONFIG_UNIX is defined.
> 
> Okay.
> 
> OL> I pulled all the other patches already, will add this one once
> OL> you resend.
> 
> Alright, well, ignore v9 I guess and hopefully we can settle on a nice
> even number 10 :)
> 

Great !

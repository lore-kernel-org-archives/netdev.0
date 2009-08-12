From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v8)
Date: Wed, 12 Aug 2009 08:36:17 -0700
Message-ID: <873a7x59ji.fsf@caffeine.danplanet.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com>
	<1249918379-29414-6-git-send-email-danms@us.ibm.com>
	<4A82DFE0.4040108@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:52723 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753735AbZHLPgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 11:36:17 -0400
In-Reply-To: <4A82DFE0.4040108@librato.com> (Oren Laadan's message of "Wed\, 12 Aug 2009 11\:29\:36 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OL> Before pulling this one, I took a quick look at this patch, and I
OL> saw that it still uses skb_morph despite the changelog and my
OL> memory...

That's correct.  We've been through several ways of allocating the
skb's, so it's definitely confusing.  We're back to skb_morph()
because I'm pre-allocating them for lock safety when traversing the
queues.  The only thing that is allocated is the actual skb structure
itself; the buffers are still shared like with skb_clone().

OL> 1) Move 'struct ckpt_hdr_socket' et-al to checkpoint_hdr.h

Okay, yeah, I guess we never really resolved the question of where
they really belong, but I'll put them back there for now.

OL> 2) Move everything that is af_unix specific from net/checkpoint.c
OL> to (a new) net/unix/checkpoint.c (prototypes probably in af_unix.h
OL> ?)

Um, I guess I can.  That will end up with a bunch of other
externally-defined interfaces between the generic and the specific
code, but I suppose I don't really have a solid argument against it.

OL> 3) Make sure that af_unix code does not compile (and is not called
OL> from net/checkpoint.c) unless CONFIG_UNIX is defined.

Okay.

OL> I pulled all the other patches already, will add this one once
OL> you resend.

Alright, well, ignore v9 I guess and hopefully we can settle on a nice
even number 10 :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

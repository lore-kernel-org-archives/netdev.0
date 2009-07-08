From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 08 Jul 2009 12:27:20 -0700
Message-ID: <87y6qzou07.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-2-git-send-email-danms@us.ibm.com>
	<4A543D82.5080408@cs.columbia.edu> <20090708140152.GC10787@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oren Laadan <orenl@cs.columbia.edu>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:33464 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753481AbZGHT1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 15:27:23 -0400
In-Reply-To: <20090708140152.GC10787@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 8 Jul 2009 09\:01\:52 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> That also caused you to skip a bunch of security_* calls (at the
SH> least here, at the recv equivalent, do_sock_getname, and at your
SH> bind at restore).

SH> I don't think simply inserting them here is the right thing to do,
SH> bc then as the main code changes this code is likely to fall out
SH> of sync.  So like Oren says, I think you need to do more re-use of
SH> the common code.  For the bind() case, for instance, write a
SH> common helper used by both sys_bind() and your restart bind, which
SH> does the security check and then calls sock->ops->bind().  It
SH> makes your patchset a bit more intrusive, but easier to maintain.

Does it make sense to modify kern_bind() (and friends) to make the
security_*() calls and then make sys_bind() and my restore code use
kern_bind()?  I don't know enough about the security stuff to know if
the other uses of kern_bind() in the kernel would trip up if the
checks are done there...

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

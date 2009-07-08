From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/2] c/r: Add AF_UNIX support (v5)
Date: Wed, 8 Jul 2009 17:01:16 -0500
Message-ID: <20090708220116.GA27127@us.ibm.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com> <1246994776-1882-2-git-send-email-danms@us.ibm.com> <4A543D82.5080408@cs.columbia.edu> <20090708140152.GC10787@us.ibm.com> <87y6qzou07.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oren Laadan <orenl@cs.columbia.edu>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55718 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbZGHWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:01:18 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n68LrUuQ030428
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 15:53:30 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n68M1Hfr243328
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 16:01:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n68M1GqZ018056
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 16:01:17 -0600
Content-Disposition: inline
In-Reply-To: <87y6qzou07.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> That also caused you to skip a bunch of security_* calls (at the
> SH> least here, at the recv equivalent, do_sock_getname, and at your
> SH> bind at restore).
> 
> SH> I don't think simply inserting them here is the right thing to do,
> SH> bc then as the main code changes this code is likely to fall out
> SH> of sync.  So like Oren says, I think you need to do more re-use of
> SH> the common code.  For the bind() case, for instance, write a
> SH> common helper used by both sys_bind() and your restart bind, which
> SH> does the security check and then calls sock->ops->bind().  It
> SH> makes your patchset a bit more intrusive, but easier to maintain.
> 
> Does it make sense to modify kern_bind() (and friends) to make the
> security_*() calls and then make sys_bind() and my restore code use
> kern_bind()?  I don't know enough about the security stuff to know if
> the other uses of kern_bind() in the kernel would trip up if the
> checks are done there...

No, since kernel_bind() is preciely for use by the kernel to create
sockets and no security checks are necessary (or make sense).  So
you just need to create a new helper shared by your function
and sys_bind() which does the security check and calls
sock->ops->bind().

-serge

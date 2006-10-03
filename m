From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Tue, 03 Oct 2006 16:10:16 -0700
Message-ID: <200610032310.k93NAGZt003069@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com> <4522605E.8000208@voltaire.com>
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:18404 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030658AbWJCXKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 19:10:20 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93NAJ8o008253
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 19:10:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93NAJnY238514
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 19:10:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93NAI5o026449
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 19:10:19 -0400
To: Or Gerlitz <ogerlitz@voltaire.com>
In-reply-to: <4522605E.8000208@voltaire.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>Sorry, but I don't follow... by saying "would be ideal to do ***it*** this
>way in all cases" what exactly is the "it" you are referring to?

	It refers to:

>>>>         You almost want to have some kind of call to induce a reload
>>>> from scratch of the multicast filter settings (along with whatever else
>>>> might be necessary to alter the hardware type on the fly), to be called
>>>> by bonding at the time the first slave is added (since slave adds happen
>>>> in user context, and can therefore hold rtnl as required by most of the
>>>> multicast address handling code).  That seems less hassle than having to
>>>> specify the hardware type and address length at module load time.

	Having this would eliminate the need to specify the hardware
type at load time, and would allow changing of the hardware type at
enslave time, rather than at device up time.  This requires fewer
changes to other things, like the initscripts or ifenslave.

	The ideal would be to allow changing of hardware type at
literally any time, allowing failover across dissimilar hardware types.
That's a lot more complicated, and has a smaller pool of potential uses.

>1st, your current recommendation to solve the link layer address
>computation of multicast groups joined by the stack before any enslavement
>actually takes place, is to instrument the bonding code such that it would
>be possible to enslave devices when the bonding device is not "up" yet.
>
>2nd, the change need to be worked out in the bonding sysfs code, the
>ifenslave program but ***also*** in packages such as /sbin/ifup and
>friends.

	Correct.  The necessary changes to initscript and sysconfig are
probably the most complex piece to organize (not necessarily the hardest
to implement, but rather the most troublesome to deploy, as it
introduces an API change).

>BTW - is the ifenslave program still supported to work with upstream
>(2.6.18 and above) kernel or it was obsoleted at some point.

	Yes, ifenslave is still supported.  It probably will be
obsoleted some day (or replaced with a script that uses sysfs), but not
anytime soon.  As far as I know, all current distros use ifenslave to
configure bonding.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

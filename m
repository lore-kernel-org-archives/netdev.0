From: Christian Borntraeger <borntrae@de.ibm.com>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 14:36:57 +0200
Message-ID: <200607181436.57841.borntrae@de.ibm.com>
References: <20060718081625.GA13830@2ka.mipt.ru> <200607181316.18461.borntrae@de.ibm.com> <20060718115125.GA6087@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:65174 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751323AbWGRMhA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 08:37:00 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k6ICax9w157740
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 12:36:59 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6ICcYvQ139256
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 13:38:34 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6ICawCx026938
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 13:36:59 +0100
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060718115125.GA6087@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 July 2006 13:51, Evgeniy Polyakov wrote:
> > I think this should be -EFAULT instead of -ERESTARTSYS, right?
>
> I have no strong feeling on what must be returned in that case.
> As far as I see, copy*user can fail due to absence of the next
> destination page, so -ERESTARTSYS makes sence, but if failure happens=
 due
> to process size limitation, -EFAULT is correct.

If I am not completely mistaken ERESTARTSYS is wrong.=20
include/linux/errno.h says userspace should never see ERESTARTSYS, ther=
efore=20
we should only return it if we were interrupted by a signal as do_signa=
l=20
takes care of ERESTARTSYS. Furthermore, copy*user transparently faults =
in=20
necessary pages as long as the address is valid in the user context.=20

> Let's change it to -EFAULT.

Thanks :-)


--=20
Mit freundlichen Gr=C3=BC=C3=9Fen / Best Regards

Christian Borntraeger
Linux Software Engineer zSeries Linux & Virtualization




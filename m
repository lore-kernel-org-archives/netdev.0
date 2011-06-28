From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are disabled
 while sleeping function kzalloc is called
Date: Tue, 28 Jun 2011 10:27:55 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A82D66F5E5@HQ1-EXCH01.corp.brocade.com>
References: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
 <20110627.160706.1453191829412045606.davem@davemloft.net>
 <DBFB1B45AF80394ABD1C807E9F28D1570453626FF0@BLRX7MCDC203.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Debashis Dutt <ddutt@Brocade.COM>,
	Jing Huang <huangj@Brocade.COM>
To: "Shyam_Iyer@Dell.com" <Shyam_Iyer@Dell.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shyam.iyer.t@gmail.com" <shyam.iyer.t@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35686 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758872Ab1F1R2J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 13:28:09 -0400
In-Reply-To: <DBFB1B45AF80394ABD1C807E9F28D1570453626FF0@BLRX7MCDC203.AMER.DELL.COM>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Shyam_Iyer@Dell.com [mailto:Shyam_Iyer@Dell.com]
>Sent: Tuesday, June 28, 2011 9:30 AM
>
>Here is try 2.
>
>I found that I had to initialize the flags variable outside the
>spin_lock_irqsave in the following way to fix the problem. The sleeping
>kzalloc function is in fact in the request_threaded_irq call which
>allocates the irq handler function and its flags arguments.
>
>Attached patch fixes the issue.

The attached patch may fix the issue in MSIX mode, however we'll continue to see the issue in INTX mode. Using a separate irq_flags may be a good idea.


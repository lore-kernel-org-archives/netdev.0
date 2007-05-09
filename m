From: "Qi, Yanling" <Yanling.Qi@lsi.com>
Subject: RE: SG_IO with >4k buffer size to iscsi sg device causes "Bad page" panic
Date: Wed, 9 May 2007 10:13:18 -0600
Message-ID: <0F08E10B769EAF4EA2C43A573B8CC87FB5703A@NAMAIL3.ad.lsil.com>
References: <4640CFC8.9020004@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<linux-iscsi-devel@lists.sourceforge.net>, <dougg@torque.net>,
	"James Bottomley" <James.Bottomley@SteelEye.com>
To: "Mike Christie" <michaelc@cs.wisc.edu>,
	<open-iscsi@googlegroups.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4640CFC8.9020004@cs.wisc.edu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Mike Christie [mailto:michaelc@cs.wisc.edu]
> Qi, Yanling wrote:
> Yeah, this problem should occur in the upstream open-iscsi iscsi code.
> open-iscsi works very similar to linux-scsi where it just sends pages
> around with sock->ops-sendpage, and it looks like sg uses
> __get_free_pages in RHEL's kernel and upstream it uses alloc_pages so
> unless there was a change in those functions or the network layer then
> we should have a similar problem.
[Qi, Yanling] 
Mike,

I tried the same test on a SLES10SP1 with open-iscsi driver (lk
2.6.16.37-0.23). It works fine.
What happens is that both "alloc_pages()" and "__get_free_pages()" will
set page_count to 1 for base page and sub-pages. Because page_count =1,
the subpages will not be recycled.

It seems the mm code has changed alloc_pages and __get_free_pages()'s
behavior along the way from 2.6.9 to 2.6.16.

Therefore, we don't have an issue in the upstream kernel and RHEL5.

0 page:ffff81007f8da240 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
1 page:ffff81007f8da278 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
2 page:ffff81007f8da2b0 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
3 page:ffff81007f8da2e8 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
4 page:ffff81007f8da320 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
5 page:ffff81007f8da358 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
6 page:ffff81007f8da390 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1
7 page:ffff81007f8da3c8 flags:0x0100000000004000
mapping:0000000000000000 mapcount:0 count:1

Thanks,
Yanling

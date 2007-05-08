From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: SG_IO with >4k buffer size to iscsi sg device causes "Bad page"
 panic
Date: Tue, 08 May 2007 14:30:16 -0500
Message-ID: <4640CFC8.9020004@cs.wisc.edu>
References: <0F08E10B769EAF4EA2C43A573B8CC87FB106C0@NAMAIL3.ad.lsil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-iscsi-devel@lists.sourceforge.net,
	"Qi, Yanling" <Yanling.Qi@lsi.com>, dougg@torque.net,
	James Bottomley <James.Bottomley@SteelEye.com>
To: open-iscsi@googlegroups.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <0F08E10B769EAF4EA2C43A573B8CC87FB106C0@NAMAIL3.ad.lsil.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Qi, Yanling wrote:
> Hi All,
> 
> This panic is related to the interactions between scsi/sg.c, iscsi
> initiator and tcp on the RHEL 2.6.9-42 kernel. But we may also have the
> similar problem with open-iscsi initiator. I will explain why we see the

Yeah, this problem should occur in the upstream open-iscsi iscsi code.
open-iscsi works very similar to linux-scsi where it just sends pages
around with sock->ops-sendpage, and it looks like sg uses
__get_free_pages in RHEL's kernel and upstream it uses alloc_pages so
unless there was a change in those functions or the network layer then
we should have a similar problem.

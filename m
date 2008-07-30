From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 30 Jul 2008 15:35:35 -0400
Message-ID: <4890C287.60508@pobox.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Karen Xie <kxie@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200807300019.m6U0JkdY012558@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karen Xie wrote:
> Cxgb3i iSCSI driver
> 
> Signed-off-by: Karen Xie <kxie@chelsio.com>
> ---
> 
>  drivers/scsi/cxgb3i/Kconfig          |    6 
>  drivers/scsi/cxgb3i/Makefile         |    5 
>  drivers/scsi/cxgb3i/cxgb3i.h         |  155 +++
>  drivers/scsi/cxgb3i/cxgb3i_init.c    |  109 ++
>  drivers/scsi/cxgb3i/cxgb3i_iscsi.c   |  800 ++++++++++++++
>  drivers/scsi/cxgb3i/cxgb3i_offload.c | 2001 ++++++++++++++++++++++++++++++++++
>  drivers/scsi/cxgb3i/cxgb3i_offload.h |  242 ++++
>  drivers/scsi/cxgb3i/cxgb3i_ulp2.c    |  692 ++++++++++++
>  drivers/scsi/cxgb3i/cxgb3i_ulp2.h    |  106 ++
>  9 files changed, 4116 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/scsi/cxgb3i/Kconfig
>  create mode 100644 drivers/scsi/cxgb3i/Makefile
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i.h
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_init.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_iscsi.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_offload.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_offload.h
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ulp2.c
>  create mode 100644 drivers/scsi/cxgb3i/cxgb3i_ulp2.h

Comments:

* SCSI drivers should be submitted via the linux-scsi@vger.kernel.org 
mailing list.

* The driver is clean and readable, well done

* From a networking standpoint, our main concern becomes how this 
interacts with the networking stack.  In particular, I'm concerned based 
on reading the source that this driver uses "TCP port stealing" rather 
than using a totally separate MAC address (and IP).

Stealing a TCP port on an IP/interface already assigned is a common 
solution in this space, but also a flawed one.  Precisely because the 
kernel and applications are unaware of this "special, magic TCP port" 
you open the potential for application problems that are very difficult 
for an admin to diagnose based on observed behavior.

So, additional information on your TCP port usage would be greatly 
appreciated.  Also, how does this interact with IPv6?  Clearly it 
interacts with IPv4...

	Jeff





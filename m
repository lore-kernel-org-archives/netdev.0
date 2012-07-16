From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: Support for multi function NIC devices
Date: Sun, 15 Jul 2012 18:40:19 -0700
Message-ID: <20657.1342402819@death.nxdomain>
References: <1342400890-32183-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44366 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab2GPBlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 21:41:31 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Sun, 15 Jul 2012 19:41:30 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id CBD0819D8050
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 01:41:10 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6G1eaEt220772
	for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 19:40:56 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6G1fRer031124
	for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 19:41:27 -0600
In-reply-to: <1342400890-32183-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anirban Chakraborty <anirban.chakraborty@qlogic.com> wrote:

>From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>
>Add support to disable bonding of interfaces belonging to the same physical port. In
>case of SRIOV or NIC partition mode, a single port of the adapter can have multiple
>NIC functions. While bonding such interfaces, it is ensured that the NIC functions
>belonging to the same physical port are not bonded together.
>
>Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>---
> Documentation/networking/ifenslave.c |  208 +++++++++++++++++++++++++++++++++-
> 1 files changed, 207 insertions(+), 1 deletions(-)
>
>diff --git a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
>index ac5debb..a0bdab9 100644
>--- a/Documentation/networking/ifenslave.c
>+++ b/Documentation/networking/ifenslave.c
>@@ -92,9 +92,14 @@
>  *    - 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
>  *	 - Code cleanup and style changes
>  *	   set version to 1.1.0
>+ *
>+ *    - 2012/07/15 - Anirban Chakraborty <anirban.chakraborty at qlogic dot com>
>+ *	 - Added support to disable bonding interfaces belonging to the
>+ *	   same physical port.
>+ *	   set version to 1.1.1

	This patch is all implemented within the ifenslave user space
program, which, to my knowledge, is not currently used by any major
distro to configure bonding.

	The configuration for bonding is typically performed by packages
such as initscripts or sysconfig, and this functionality would likely
need to go there.

	The only real use for ifenslave.c is on kernels without sysfs
compiled in.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

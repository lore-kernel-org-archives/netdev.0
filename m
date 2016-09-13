From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [RFC 02/11] Add RoCE driver framework
Date: Tue, 13 Sep 2016 09:46:23 -0500
Message-ID: <018901d20dcd$98d0c040$ca7240c0$@opengridcomputing.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com> <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <Yuval.Mintz@qlogic.com>, <Ariel.Elior@qlogic.com>,
        <Michal.Kalderon@qlogic.com>, <rajesh.borundia@qlogic.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>
To: "'Ram Amrani'" <Ram.Amrani@qlogic.com>, <dledford@redhat.com>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:44273 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758612AbcIMOqU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:46:20 -0400
In-Reply-To: <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adds a skeletal implementation of the qed* RoCE driver -
> basically the ability to communicate with the qede driver and
> receive notifications from it regarding various init/exit events.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Ram Amrani <Ram.Amrani@qlogic.com>
> ---
>  drivers/infiniband/Kconfig                   |   2 +
>  drivers/infiniband/hw/Makefile               |   1 +
>  drivers/infiniband/hw/qedr/Kconfig           |   7 +
>  drivers/infiniband/hw/qedr/Makefile          |   3 +
>  drivers/infiniband/hw/qedr/main.c            | 293 +++++++++++++++++++++++++
>  drivers/infiniband/hw/qedr/qedr.h            |  60 ++++++
>  drivers/net/ethernet/qlogic/qede/Makefile    |   1 +
>  drivers/net/ethernet/qlogic/qede/qede.h      |   9 +
>  drivers/net/ethernet/qlogic/qede/qede_main.c |  35 ++-
>  drivers/net/ethernet/qlogic/qede/qede_roce.c | 309
> +++++++++++++++++++++++++++
>  include/linux/qed/qed_if.h                   |   3 +-
>  include/linux/qed/qede_roce.h                |  88 ++++++++
>  include/uapi/linux/pci_regs.h                |   3 +
>  13 files changed, 803 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/infiniband/hw/qedr/Kconfig
>  create mode 100644 drivers/infiniband/hw/qedr/Makefile
>  create mode 100644 drivers/infiniband/hw/qedr/main.c
>  create mode 100644 drivers/infiniband/hw/qedr/qedr.h
>  create mode 100644 drivers/net/ethernet/qlogic/qede/qede_roce.c
>  create mode 100644 include/linux/qed/qede_roce.h

<snip>

> @@ -189,8 +189,7 @@ static int qede_netdev_event(struct notifier_block *this,
> unsigned long event,
>  	struct ethtool_drvinfo drvinfo;
>  	struct qede_dev *edev;
> 
> -	/* Currently only support name change */
> -	if (event != NETDEV_CHANGENAME)
> +	if ((event != NETDEV_CHANGENAME) && (event !=
> NETDEV_CHANGEADDR))

nit: You don't really need the extra parens here.

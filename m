From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH] net: netxen: correct sysfs bin attribute return code
Date: Wed, 27 May 2015 08:32:08 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B93E464E308@avmb3.qlogic.org>
References: <1432601404-24632-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Vladimir Zapolskiy <vz@mleia.com>,
	David Miller <davem@davemloft.net>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:38870 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935AbbE0IcO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 04:32:14 -0400
In-Reply-To: <1432601404-24632-1-git-send-email-vz@mleia.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Vladimir Zapolskiy [mailto:vz@mleia.com]
> Sent: Tuesday, May 26, 2015 6:20 AM
> To: David Miller; Manish Chopra; Sony Chacko; Rajesh Borundia
> Cc: netdev
> Subject: [PATCH] net: netxen: correct sysfs bin attribute return code
> 
> If read() syscall requests unexpected number of bytes from "dimm" binary
> attribute file, return EINVAL instead of EPERM.
> 
> At the same time pin down sysfs file size to the fixed sizeof(struct
> netxen_dimm_cfg), which allows to exploit some missing sanity checks from
> kernfs (file boundary checks vs offset etc.)
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> index e0c31e3..6409a06 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> @@ -3025,9 +3025,9 @@ netxen_sysfs_read_dimm(struct file *filp, struct
> kobject *kobj,
>  	u8 dw, rows, cols, banks, ranks;
>  	u32 val;
> 
> -	if (size != sizeof(struct netxen_dimm_cfg)) {
> +	if (size < attr->size) {
>  		netdev_err(netdev, "Invalid size\n");
> -		return -1;
> +		return -EINVAL;
>  	}
> 
>  	memset(&dimm, 0, sizeof(struct netxen_dimm_cfg)); @@ -3137,7
> +3137,7 @@ out:
> 
>  static struct bin_attribute bin_attr_dimm = {
>  	.attr = { .name = "dimm", .mode = (S_IRUGO | S_IWUSR) },
> -	.size = 0,
> +	.size = sizeof(struct netxen_dimm_cfg),
>  	.read = netxen_sysfs_read_dimm,
>  };
> 

Acked-by: Manish Chopra <manish.chopra@qlogic.com>

Thanks.

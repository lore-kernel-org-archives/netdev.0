From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 4/8] net/ncsi: Add debugging infrastructurre
Date: Thu, 13 Apr 2017 03:41:46 -0700
Message-ID: <1492080106.28586.13.camel@perches.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
         <1492069701-20772-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0202.hostedemail.com ([216.40.44.202]:41413 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750915AbdDMKlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 06:41:53 -0400
In-Reply-To: <1492069701-20772-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-13 at 17:48 +1000, Gavin Shan wrote:
> This creates debugfs directories as NCSI debugging infrastructure.
> With the patch applied, We will see below debugfs directories. Every
> NCSI package and channel has one corresponding directory. Other than
> presenting the NCSI topology, No real function has been achieved
> through these debugfs directories so far.
> 
>      /sys/kernel/debug/ncsi/eth0
>      /sys/kernel/debug/ncsi/eth0/p0
>      /sys/kernel/debug/ncsi/eth0/p0/c0
>      /sys/kernel/debug/ncsi/eth0/p0/c1

[]

> diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
[]
> +int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp)
> +{
> +	if (WARN_ON_ONCE(ndp->dentry))
> +		return 0;
> +
> +	if (!ncsi_dentry) {
> +		ncsi_dentry = debugfs_create_dir("ncsi", NULL);
> +		if (!ncsi_dentry) {
> +			pr_warn("NCSI: Cannot create /sys/kernel/debug/ncsi\n");
> +			return -ENOENT;

debugfs does not have a fixed path.

Most error messages for this just use something like
	pr_<level>("Failed to create debugfs directory '%s'\n", foo)
And most failures don't emit any error message at all.

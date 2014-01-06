From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bonding: fix kstrtou8() return value verification in num_peer_notif
Date: Mon, 6 Jan 2014 09:02:18 -0800
Message-ID: <0E8BD1B8-4D60-4292-8694-CF0E988AA2BD@cumulusnetworks.com>
References: <1389005680-9063-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46697 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470AbaAFRCZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 12:02:25 -0500
In-Reply-To: <1389005680-9063-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 6, 2014, at 2:54 AM, Veaceslav Falico <vfalico@redhat.com> wrote:

> It returns 0 in case of success, !0 error otherwise. Fix the improper error
> verification.
> 
> Fixes: 2c9839c143bbc ("bonding: add num_grat_arp attribute netlink support")
> CC: sfeldma@cumulusnetworks.com
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
> drivers/net/bonding/bond_sysfs.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 9a1ea4a..011f163 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -776,7 +776,7 @@ static ssize_t bonding_store_num_peer_notif(struct device *d,
> 	int ret;
> 
> 	ret = kstrtou8(buf, 10, &new_value);
> -	if (!ret) {
> +	if (ret) {
> 		pr_err("%s: invalid value %s specified.\n",
> 		       bond->dev->name, buf);
> 		return ret;
> -- 
> 1.8.4

Thanks!

Acked-by: Scott Feldman <sfeldma@cumulusnetworks.com>
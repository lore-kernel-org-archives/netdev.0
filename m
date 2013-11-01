From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [patch -next] bonding: bond_get_size() returns wrong size
Date: Fri, 1 Nov 2013 11:41:00 +0100
Message-ID: <20131101104100.GU692@redhat.com>
References: <20131101101844.GA29795@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131101101844.GA29795@longonot.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 01, 2013 at 01:18:44PM +0300, Dan Carpenter wrote:
>There is an extra semi-colon so bond_get_size() doesn't return the
>correct value.
>
>Fixes: ec76aa49855f ('bonding: add Netlink support active_slave option')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Hrm, how does it even build. Good catch, thanks.

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
>index 7661261..40e7b1c 100644
>--- a/drivers/net/bonding/bond_netlink.c
>+++ b/drivers/net/bonding/bond_netlink.c
>@@ -82,8 +82,8 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
>
> static size_t bond_get_size(const struct net_device *bond_dev)
> {
>-	return nla_total_size(sizeof(u8));	/* IFLA_BOND_MODE */
>-		+ nla_total_size(sizeof(u32));	/* IFLA_BOND_ACTIVE_SLAVE */
>+	return nla_total_size(sizeof(u8)) +	/* IFLA_BOND_MODE */
>+		nla_total_size(sizeof(u32));	/* IFLA_BOND_ACTIVE_SLAVE */
> }
>
> static int bond_fill_info(struct sk_buff *skb,

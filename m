From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next 08/27] bonding: remove
 bond_for_each_slave_reverse()
Date: Wed, 11 Sep 2013 01:53:14 +0000 (UTC)
Message-ID: <l0oiea$jo6$2@ger.gmane.org>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
 <1378846691-9717-9-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:47348 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889Ab3IKBxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 21:53:36 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VJZcc-0002sq-Ed
	for netdev@vger.kernel.org; Wed, 11 Sep 2013 03:53:34 +0200
Received: from 117.57.109.128 ([117.57.109.128])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 03:53:34 +0200
Received: from xiyou.wangcong by 117.57.109.128 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 03:53:34 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Sep 2013 at 20:57 GMT, Veaceslav Falico <vfalico@redhat.com> wrote:
> We only use it in rollback scenarios and can easily use the standart
> bond_for_each_dev() instead.
>

What you remove actually is bond_for_each_slave_continue_reverse()...
$subject needs to be fixed.


> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index c3dcc6b..46f6b40 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1246,9 +1246,9 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
>   */
>  static int alb_set_mac_address(struct bonding *bond, void *addr)
>  {
> -	char tmp_addr[ETH_ALEN];
> -	struct slave *slave;
> +	struct slave *slave, *rollback_slave;
>  	struct sockaddr sa;
> +	char tmp_addr[ETH_ALEN];

Why are you moving tmp_addr[]?

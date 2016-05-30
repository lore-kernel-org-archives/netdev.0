From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: Fix port forwarding mask
Date: Mon, 30 May 2016 10:17:01 -0400
Message-ID: <87inxvbpgi.fsf@ketchup.mtl.sfl>
References: <1464600944-30782-1-git-send-email-Wojciech.Dubowik@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
	Wojciech Dubowik <Wojciech.Dubowik@neratec.com>
To: Wojciech Dubowik <Wojciech.Dubowik@neratec.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43954 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997AbcE3ORG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 10:17:06 -0400
In-Reply-To: <1464600944-30782-1-git-send-email-Wojciech.Dubowik@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wojciech, David,

Wojciech Dubowik <Wojciech.Dubowik@neratec.com> writes:

> Port's vlan table is specified by bit mask and not by number.
> Only 4.4.x kernels are affected.
>
> Signed-off-by: Wojciech Dubowik <Wojciech.Dubowik@neratec.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 2dea39b..3e074d4 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2150,7 +2150,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>  	 * database, and allow every port to egress frames on all other ports.
>  	 */
>  	reg = BIT(ps->num_ports) - 1; /* all ports */
> -	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~port);
> +	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~BIT(port));
>  	if (ret)
>  		goto abort;

Commit be1faa92e83b ("net: dsa: mv88e6xxx: fix port VLAN maps") in
net/master already fixes this.

But indeed v4.5 contains be1faa92e83b but not v4.4.

Thanks,

        Vivien

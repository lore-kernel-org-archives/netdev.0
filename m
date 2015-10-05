From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 10/14] rocker: pass "learning" value as a
 parameter to rocker_port_set_learning
Date: Mon, 5 Oct 2015 15:16:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBAC9ED@AcuExch.aculab.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
 <1443993949-3915-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"ast@plumgrid.com" <ast@plumgrid.com>
To: 'Jiri Pirko' <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:62883 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022AbbJEPRS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:17:18 -0400
In-Reply-To: <1443993949-3915-11-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 04 October 2015 22:26
> Be consistent with the rest of the setting functions, and pass
> "learning" as a bool function parameter.
...
> diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
> index fb7e8c2..d9329a7 100644
> --- a/drivers/net/ethernet/rocker/rocker_main.c
> +++ b/drivers/net/ethernet/rocker/rocker_main.c
> @@ -1634,6 +1634,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
>  				  struct rocker_desc_info *desc_info,
>  				  void *priv)
>  {
> +	bool learning = *(int *)priv;
...
> static int rocker_port_set_learning(struct rocker_port *rocker_port,
> -				    struct switchdev_trans *trans)
> +				    struct switchdev_trans *trans,
> +				    bool learning)
> {
>  	return rocker_cmd_exec(rocker_port, trans, 0,
>  			       rocker_cmd_set_port_learning_prep,
> -			       NULL, NULL, NULL);
> +			       &learning, NULL, NULL);

This hit my 'casting between integer pointer types' bell.
It is clearly wrong if 'sizeof (bool) != sizeof (int)'.

It is much safer to only ever cast structure types to/from 'void *'.

	David

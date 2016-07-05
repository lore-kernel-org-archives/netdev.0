From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch net-next 01/16] net: add dev arg to
 ndo_neigh_construct/destroy
Date: Tue, 5 Jul 2016 11:03:36 +0000
Message-ID: <CO2PR11MB0088EB72A42815296CD1D93397390@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
 <1467710872-20056-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"nogahf@mellanox.com" <nogahf@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"ivecera@redhat.com" <ivecera@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0103.outbound.protection.outlook.com ([104.47.32.103]:10112
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754829AbcGEMhV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:37:21 -0400
In-Reply-To: <1467710872-20056-2-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As the following patch will allow upper devices to follow the call down lower
> devices, we need to add dev here and not rely on n->dev.

How does all of this relates to neigh_alloc()? Is it being called only for the
lower devices?
I'm asking as it appears that __neigh_create() would allocates memory
based on some dev's neigh_priv_len, then propagate it via
ndo_neigh_construct() [which you change in patch 2] - looks like the current
implementers of this function assume the private entry is always theirs. E.g.,

> -static int clip_constructor(struct neighbour *neigh)
> +static int clip_constructor(struct net_device *dev, struct neighbour
> +*neigh)
>  {
>  	struct atmarp_entry *entry = neighbour_priv(neigh);
> 

[Writing with absolute zero knowledge of this; perhaps this is all bollocks]

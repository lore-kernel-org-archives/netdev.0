From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/16] net: add dev arg to
 ndo_neigh_construct/destroy
Date: Tue, 5 Jul 2016 14:05:22 +0200
Message-ID: <20160705120522.GA1984@nanopsycho.orion>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
 <1467710872-20056-2-git-send-email-jiri@resnulli.us>
 <CO2PR11MB0088EB72A42815296CD1D93397390@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
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
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34748 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844AbcGEMFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:05:25 -0400
Received: by mail-wm0-f43.google.com with SMTP id 187so26570331wmz.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 05:05:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CO2PR11MB0088EB72A42815296CD1D93397390@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 05, 2016 at 01:03:36PM CEST, Yuval.Mintz@qlogic.com wrote:
>> As the following patch will allow upper devices to follow the call down lower
>> devices, we need to add dev here and not rely on n->dev.
>
>How does all of this relates to neigh_alloc()? Is it being called only for the
>lower devices?

This is called for all neighs.


>I'm asking as it appears that __neigh_create() would allocates memory
>based on some dev's neigh_priv_len, then propagate it via
>ndo_neigh_construct() [which you change in patch 2] - looks like the current
>implementers of this function assume the private entry is always theirs. E.g.,

neigh_priv_len does not take stacked devices into account.


>
>> -static int clip_constructor(struct neighbour *neigh)
>> +static int clip_constructor(struct net_device *dev, struct neighbour
>> +*neigh)
>>  {
>>  	struct atmarp_entry *entry = neighbour_priv(neigh);
>> 
>
>[Writing with absolute zero knowledge of this; perhaps this is all bollocks]

Better to study the code first before you comment, next time.

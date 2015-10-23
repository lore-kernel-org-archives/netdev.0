From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Fri, 23 Oct 2015 18:44:16 -0400
Message-ID: <20151023224416.GA10185@ketchup.mtl.sfl>
References: <1445625487-16313-1-git-send-email-f.fainelli@gmail.com>
 <20151023192824.GA21943@ketchup.mtl.sfl>
 <562A968E.9020303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	andrew@lunn.ch, linux@roeck-us.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34914 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbJWWoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 18:44:19 -0400
Content-Disposition: inline
In-Reply-To: <562A968E.9020303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Friday 23 (43) 01:20 PM, Florian Fainelli wrote:
> On 23/10/15 12:28, Vivien Didelot wrote:
> > On Oct. Friday 23 (43) 11:38 AM, Florian Fainelli wrote:
> >> +static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
> >> +			      const struct switchdev_obj_port_fdb *fdb)
> >> +{
> >> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> >> +
> >> +	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, false);
> >> +}
> > 
> > I'm wondering if you are populating the FDB of the invalid VLAN 0 here.
> > 
> > Does your ARL consider that fdb->vid == 0 means "this port's FDB" and
> > not "FDB of VLAN 0"?
> 
> (please trim your replies)

Noted, thanks.

> I do not think this matters right now, since 802.1q is not currently
> enabled/supported in the driver, but maybe I am trivializing this?

I meant that, when you issue the following command:

    bridge fdb add de:ea:be:ef:12:34 dev swp3

you will get vid == 0 in bcm_sf2_sw_fdb_add(). So I was wondering if
your code was populating the FDB of the VLAN 0, instead of the choosen
FDB associated to the given port.

Thanks,
-v

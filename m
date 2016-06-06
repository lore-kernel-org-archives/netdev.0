From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/9] net: dsa: Initialize CPU port ethtool ops
 per tree
Date: Mon, 6 Jun 2016 04:40:05 +0200
Message-ID: <20160606024005.GJ12165@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-11-git-send-email-f.fainelli@gmail.com>
 <20160604203855.GH2063@lunn.ch>
 <5754A7AD.1020208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60049 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbcFFCkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2016 22:40:09 -0400
Content-Disposition: inline
In-Reply-To: <5754A7AD.1020208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 05, 2016 at 03:29:01PM -0700, Florian Fainelli wrote:
> Le 04/06/2016 13:38, Andrew Lunn a =E9crit :
> >> index e8386157de30..938262010524 100644
> >> --- a/net/dsa/dsa2.c
> >> +++ b/net/dsa/dsa2.c
> >> @@ -346,7 +346,7 @@ static int dsa_ds_apply(struct dsa_switch_tree=
 *dst, struct dsa_switch *ds)
> >>  			continue;
> >>  	}
> >> =20
> >> -	return 0;
> >> +	return dsa_cpu_port_ethtool_setup(dst, ds);
> >=20
> > Hi Florian
> >=20
> > This is wrong. Remember, multiple CPU ports. You need to apply this=
 to
> > each CPU port.
>=20
> We do not quite support that properly though, we still do not create =
a
> "cpu" network device, and there is only a single master netdev per
> dsa_switch at the moment, making the secondary CPU port interfaces
> impossible to overlay their backing "master" netdev with their compan=
ion
> switch port statistics at the moment.

Hi Florian.

Using that argument, you should probably call
dsa_cpu_port_ethtool_setup() in dsa_dst_apply, since that is what
manipulates the master interface to make it handle DSA frames.

	    Andrew

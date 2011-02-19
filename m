From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v6 0/9] net: Unified offload configuration
Date: Sat, 19 Feb 2011 13:28:04 +0100
Message-ID: <20110219122804.GA28326@rere.qmqm.pl>
References: <20110217.145611.229745070.davem@davemloft.net> <20110218142238.GA18099@rere.qmqm.pl> <1298039371.2211.9.camel@localhost> <20110218.120617.71104636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47046 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908Ab1BSM2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 07:28:06 -0500
Content-Disposition: inline
In-Reply-To: <20110218.120617.71104636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 18, 2011 at 12:06:17PM -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 18 Feb 2011 14:29:31 +0000
>=20
> > On Fri, 2011-02-18 at 15:22 +0100, Micha=B3 Miros=B3aw wrote:
> >> On Thu, Feb 17, 2011 at 02:56:11PM -0800, David Miller wrote:
> > [...]
> >> > Please get rid of that annoying message spit out by netif_featur=
es_change(),
> >> > it's just spam.  If we want notifications for stuff like this, u=
se a
> >> > non-unicast netlink message so those who want to hear it can do =
so.
> >> You mean netdev_update_features() "Features changed" message? Is i=
t ok
> >> to just demote it to DEBUG level or you want to remove it altogeth=
er?
> >> What about netdev_fix_features() messages?
> > I think you need to emit these messages at 'error' severity when fi=
xing
> > up features for a newly-added device, but at 'debug' later on.
> I get one several minutes after every boot for a completely
> unregistered device for some reason:
>=20
> [119704.730965] (unregistered net_device): Features changed: 0x000110=
65 -> 0x00015065

Hmm. That's because netdev_update_features() get's called before changi=
ng
netdev->reg_state. I wonder if moving the feature update just after
"dev->reg_state =3D NETREG_REGISTERED;" will be correct fix.

Best Regards,
Micha=B3 Miros=B3aw

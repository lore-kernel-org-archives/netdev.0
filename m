From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 02/10] e1000e: add timeout for TX HW time
 stamping work
Date: Fri, 14 Mar 2014 11:44:15 -0700
Message-ID: <1394822655.3253.7.camel@joe-AO722>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-3-git-send-email-kubakici@wp.pl>
	 <1394819317.3253.3.camel@joe-AO722> <20140314190242.4bba2b42@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jakub =?UTF-8?Q?Kici=C5=84ski?= <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0170.hostedemail.com ([216.40.44.170]:54944 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755985AbaCNSoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 14:44:19 -0400
In-Reply-To: <20140314190242.4bba2b42@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-14 at 19:02 +0100, Jakub Kici=C5=84ski wrote:
> On Fri, 14 Mar 2014 10:48:37 -0700, Joe Perches wrote:
> > On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> > > Hardware may fail to report time stamp e.g.:
> > >  - when hardware time stamping is not enabled
> > >  - when time stamp is requested shortly after ifup
> >=20
> > trivia:
> >=20
> > > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers=
/net/ethernet/intel/e1000e/netdev.c
> > []
> > > @@ -1155,6 +1155,12 @@ static void e1000e_tx_hwtstamp_work(struct=
 work_struct *work)
> > >  		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
> > >  		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> > >  		adapter->tx_hwtstamp_skb =3D NULL;
> > > +	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
> > > +			      + adapter->tx_timeout_factor * HZ)) {
> > > +		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> > > +		adapter->tx_hwtstamp_skb =3D NULL;
> > > +		adapter->tx_hwtstamp_timeouts++;
> > > +		e_warn("clearing Tx timestamp hang");
> >=20
> > Missing \n termination
>=20
> I copied that line from ixgbe and assumed that the magic macro adds
> termination...
>=20
> I see that igb and i40e also lack the \n on similar messages.

There's a bunch of them.

>  Can I fix
> them all in a single follow-up patch?

There are also a bunch of _dbg messages that lack that
\n and those seem to be function tracing uses that should
just be deleted.

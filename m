From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [v2 Patch 1/2] s2io: add dynamic LRO disable support
Date: Tue, 15 Jun 2010 09:07:47 -0700
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EF15A949F@FRE1EXCH02.hq.exar.com>
References: <20100609100928.6573.14199.sendpatchset@localhost.localdomain>
 <1276092058.2093.1.camel@achroite.uk.solarflarecom.com>
 <FCA91A92EE52B041906A0358FC28FCC38EF13E71B8@FRE1EXCH02.hq.exar.com>
 <4C173932.7010101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:8992 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753420Ab0FOQHu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:07:50 -0400
In-Reply-To: <4C173932.7010101@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> On Wed, 2010-06-09 at 06:05 -0400, Amerigo Wang wrote:
> >> [...]
> >>> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
> >>> +{
> >>> +   struct s2io_nic *sp = netdev_priv(dev);
> >>> +   int rc = 0;
> >>> +   int changed = 0;
> >>> +
> >>> +   if (data&  ETH_FLAG_LRO) {
> >>> +           if (lro_enable) {
> >>> +                   if (!(dev->features&  NETIF_F_LRO)) {
> >>> +                           dev->features |= NETIF_F_LRO;
> >>> +                           changed = 1;
> >>> +                   }
> >>> +           } else
> >>> +                   rc = -EINVAL;
> >>> +   } else if (dev->features&  NETIF_F_LRO) {
> >>> +           dev->features&= ~NETIF_F_LRO;
> >>> +           changed = 1;
> >>> +   }
> >>> +
> >>> +   if (changed&&  netif_running(dev)) {
> >>> +           s2io_stop_all_tx_queue(sp);
> >>> +           s2io_card_down(sp);
> >>> +           sp->lro = dev->features&  NETIF_F_LRO;
> >>> +           rc = s2io_card_up(sp);
> >>> +           s2io_start_all_tx_queue(sp);
> >> [...]
> >>
> >> Is it safe to call s2io_start_all_tx_queue() if s2io_card_up() failed?
> > Ben,
> > Good point. If s2io_card_up() fails the chip will not be accessed, so
> it's safe but all transmit skbs will be freed without the user knowing the
> reason for failing to transmit or receive for that matter.  The other
> option is to return with a failure and get the watchdog timer reset the
> adapter.
> >
>
> (Sorry for the delay, I was on vacation.)
>
> So it seems the latter option is better?
Yes, this will work.

Thanks,
Ram

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.

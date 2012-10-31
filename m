From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac:
 replace sys time stamps with raw ones instead.
Date: Wed, 31 Oct 2012 08:57:43 +0100
Message-ID: <20121031075743.GA2327@netboy.at.omicron.at>
References: <cover.1348851539.git.richardcochran@gmail.com>
 <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
 <CAA_GA1f6BuaY+xtMjGrvaaAoP=Z0=o3NZEwjt6F-5zYho0L7OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Miroslav Lichvar <mlichvar@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	device-drivers-devel@blackfin.uclinux.org,
	Jacob Keller <jacob.e.keller@intel.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Patrick Ohly <patrick.ohly@intel.com>,
	David Miller <davem@davemloft.net>
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33642 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab2JaH54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 03:57:56 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so575749eek.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 00:57:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA_GA1f6BuaY+xtMjGrvaaAoP=Z0=o3NZEwjt6F-5zYho0L7OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 02:47:21PM +0800, Bob Liu wrote:
> > @@ -861,15 +854,9 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
> >                         regval = bfin_read_EMAC_PTP_TXSNAPLO();
> >                         regval |= (u64)bfin_read_EMAC_PTP_TXSNAPHI() << 32;
> >                         memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> > -                       ns = timecounter_cyc2time(&lp->clock,
> > -                                       regval);
> > -                       timecompare_update(&lp->compare, ns);
> > +                       ns = regval >> lp->shift;
> 
> Why not set ns = regval << lp->shift?
> I think it's conflicted with patch [3/4]

Yes, you are right. I will fix this in V2.

> > @@ -892,51 +879,25 @@ static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
> >
> >         regval = bfin_read_EMAC_PTP_RXSNAPLO();
> >         regval |= (u64)bfin_read_EMAC_PTP_RXSNAPHI() << 32;
> > -       ns = timecounter_cyc2time(&lp->clock, regval);
> > -       timecompare_update(&lp->compare, ns);
> > +       ns = regval >> lp->shift;
> 
> So is here.

Thanks for the careful review,
Richard

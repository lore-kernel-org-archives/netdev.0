From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac:
 replace sys time stamps with raw ones instead.
Date: Tue, 30 Oct 2012 14:41:12 +0100
Message-ID: <20121030134112.GB2283@netboy.at.omicron.at>
References: <cover.1348851539.git.richardcochran@gmail.com>
 <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
 <CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52484 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab2J3Nl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 09:41:27 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so159538eek.19
        for <netdev@vger.kernel.org>; Tue, 30 Oct 2012 06:41:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 30, 2012 at 05:17:51PM +0800, Bob Liu wrote:

> > @@ -892,51 +879,25 @@ static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
> >
> >         regval = bfin_read_EMAC_PTP_RXSNAPLO();
> >         regval |= (u64)bfin_read_EMAC_PTP_RXSNAPHI() << 32;
> > -       ns = timecounter_cyc2time(&lp->clock, regval);
> > -       timecompare_update(&lp->compare, ns);
> > +       ns = regval >> lp->shift;
> >         memset(shhwtstamps, 0, sizeof(*shhwtstamps));
> >         shhwtstamps->hwtstamp = ns_to_ktime(ns);
> > -       shhwtstamps->syststamp = timecompare_transform(&lp->compare, ns);
> > -
> > -       bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp, &shhwtstamps->syststamp, &lp->compare);
> > -}
> 
> In my test,  system time in slave side can't be updated although here
> have set shhwtstamps->hwtstamp = ns_to_ktime(ns).
> Any idea?

So the "system time" in shhwtstamps->syststamp has been removed. Only
the raw value remains.

Or what do you mean by "can't be updated"?

How did you test this?

I would suggest the following:

1. test using Documentation/ptp/testptp to make sure the clock is
   working reasconably.

2. try ptp4l from http://linuxptp.sourceforge.net/ to make sure the
   time stamping is working

Thanks,
Richard

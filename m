From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] net: added support for 40GbE link.
Date: Tue, 19 Jun 2012 15:11:34 +0100
Message-ID: <1340115094.2692.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120619.002905.922583388766089167.davem@davemloft.net>
	 <5D6C0ABE6A236946864C45679362BBE20AC52269@CMEXMB1.ad.emulex.com>
	 <20120619.003517.2067426285873138772.davem@davemloft.net>
	 <5D6C0ABE6A236946864C45679362BBE20AC5227D@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <Parav.Pandit@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13940 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751301Ab2FSOLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 10:11:40 -0400
In-Reply-To: <5D6C0ABE6A236946864C45679362BBE20AC5227D@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 07:42 +0000, Parav.Pandit@Emulex.Com wrote:
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, June 19, 2012 1:05 PM
> > To: Pandit, Parav
> > Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
> > Subject: Re: [PATCH] net: added support for 40GbE link.
> > 
> > From: <Parav.Pandit@Emulex.Com>
> > Date: Tue, 19 Jun 2012 07:33:12 +0000
> > 
> > > Should eventually all net driver should remove using SPEED_xxxxxx and
> > start using hard coded value of 10, 100, 1000, 20000?
> > 
> > No, the ones that exist can stay, just no new ones.
> > 
> So driver which supports 40Gpbs, 100Gbps should hardcode to 40000, 100000 respectively?

Right.

> > > That means ethtool_cmd_speed() should not be called in this function?
> > 
> > Ben said that it must be called, what are you talking about?
> 
> Sorry, I wanted to ask - Do you need switch case for speed like below new code or its should be speed independent code?
>                 switch (ethtool_cmd_speed()) {
>                 case SPEED_100:
>                 case SPEED_10:
>                         return DEFAULT_PRB_RETIRE_TOV;
>                 default:
>                         msec = 1;
>                         div = ethtool_cmd_speed() / 1000;
>                         break;
>                 /*
>                 }

I was thinking of something like:

		u64 speed = ethtool_cmd_speed(&ecmd);
		if (speed < 1000 || speed == SPEED_UNKNOWN)
			return DEFAULT_PRB_RETIRE_TOV;
		msec = 1;
		div = speed / 1000;

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

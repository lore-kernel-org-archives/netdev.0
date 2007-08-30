From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Thu, 30 Aug 2007 04:38:09 +0300
Message-ID: <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>
References: <2713029743177393055@pripojeni.net>
	 <280951420471148977@pripojeni.net>
	 <20070828171330.GD29343@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Christoph Hellwig" <hch@infradead.org>,
	"Jiri Slaby" <jirislaby@gmail.com>, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:2789 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758923AbXH3BiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 21:38:10 -0400
Received: by py-out-1112.google.com with SMTP id u77so2566426pyb
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 18:38:10 -0700 (PDT)
In-Reply-To: <20070828171330.GD29343@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/28, Christoph Hellwig <hch@infradead.org>:
> On Tue, Aug 28, 2007 at 12:01:30PM -0400, Jiri Slaby wrote:
> > +config ATH5K_AR5210
> > +     bool "Support AR5210"
> > +     depends on ATH5K
> > +     default y
> > +
> > +config ATH5K_AR5211
> > +     bool "Support AR5211"
> > +     depends on ATH5K
> > +     default y
> > +
> > +config ATH5K_AR5212
> > +     bool "Support AR5212"
> > +     depends on ATH5K
> > +     default y
>
> Please don't add more default statements.
>
> Also this whole patch seems rather pointless.  It saves only
> very little and turns the driver into a complete ifdef maze.

It saves big chunks of code (not only initial register settings
arrays) and we'll extend it's use more inside ath5k_hw.c Trust me this
is a very useful step, eg. check out descriptor processing / setup or
PHY functions (calibrate/channel set etc). For example AR5210 mac chip
only comes with RF5110 phy chip so we can get rid of RF5111/RF5112
code, AR5211 comes with RF5111 so we can get rid of RF5110 and RF5112
code and AR5212 comes with RF5111 or RF5112 so we get rid of RF5110.
This thing also saves lots of checks during runtime (some of them
happen verry frequently, eg. durring descriptor processing). Also most
people will use 5212 code only, 5211 cards are on some old laptops and
5210, well i couldn't even find  a 5210 for actual testing :P

-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick

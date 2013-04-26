From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 05/21] atm: he: use mdelay instead of large udelay constants
Date: Fri, 26 Apr 2013 09:21:59 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7203@saturn3.aculab.com>
References: <1366910944-3033663-1-git-send-email-arnd@arndb.de> <1366910944-3033663-6-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>,
	"Chas Williams" <chas@cmf.nrl.navy.mil>,
	<linux-atm-general@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: "Arnd Bergmann" <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1366910944-3033663-6-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ARM cannot handle udelay for more than 2 miliseconds, so we
> should use mdelay instead for those.
...
> @@ -1055,7 +1055,7 @@ static int he_start(struct atm_dev *dev)
>  	he_writel(he_dev, 0x0, RESET_CNTL);
>  	he_writel(he_dev, 0xff, RESET_CNTL);
> 
> -	udelay(16*1000);	/* 16 ms */
> +	mdelay(16);	/* 16 ms */
>  	status = he_readl(he_dev, RESET_CNTL);

16ms seems a long time to spin.
I'd have thought a sleep would be more appropriate.
Since this looks like timing a hardware reset pulse
it can't matter if it is somewhat longer.

	David

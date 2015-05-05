From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] adm8211: fix checkpatch errors for indentation and new
 line around switch-case
Date: Tue, 05 May 2015 06:50:52 -0700
Message-ID: <1430833852.7191.7.camel@perches.com>
References: <5548B192.8020808@lysator.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Okash Khawaja <okash.khawaja@gmail.com>, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Rosin <peda@lysator.liu.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5548B192.8020808@lysator.liu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-05 at 14:03 +0200, Peter Rosin wrote:
> > diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
[]
> > @@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
> >  		pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
> >  
> >  		switch (cline) {
[]
> > +		case  0x8:
> > +			reg |= (0x1 << 14);
> > +			break;
> > +		case 0x16:
> > +			reg |= (0x2 << 14);
> > +			break;
> > +		case 0x32:
> > +			reg |= (0x3 << 14);
> > +			break;
> > +		default:
> > +			reg |= (0x0 << 14);
> > +			break;
> >  		}
> >  	}
> >  
> 
> Those 0x16/0x32 hexadecimal case-selectors looking suspiciously like
> decimal bits need a comment if they are in fact correct, which I doubt.

Good spot.

As it's testing PCI_CACHE_LINE_SIZE,
they seem very much broken.

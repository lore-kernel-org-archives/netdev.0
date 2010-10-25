From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Mon, 25 Oct 2010 16:23:04 +0200
Message-ID: <1288016584.3716.2.camel@jlt3.sipsolutions.net>
References: <1287952327-9924-1-git-send-email-sez@debian.org>
	 <4CC5851D.1040204@lwfinger.net>  <4CC5900A.2050209@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Serafeim Zanikolas <sez@debian.org>, herton@mandriva.com.br,
	linville@tuxdriver.com, joe@perches.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hin-Tak Leung <htl10@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CC5900A.2050209@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-10-25 at 15:11 +0100, Hin-Tak Leung wrote:

> >> Despite the indicated intention in comment, the kmalloc() call was not
> >> explicitly requesting memory from ZONE_DMA.

> I had a quick look for similiar constructs and AFAIK only the b43/b43legacy 
> drivers uses DMA buffers. Seems to be a rare practice. Is that something we 
> should or should not do?

I think there's some confusion here about ZONE_DMA vs. DMA-able memory.
All memory you get with kmalloc can be used for DMA, GFP_DMA means using
ZONE_DMA which is a hack for ISA (and in b43 maybe PCMCIA/Cardbus)
devices to put memory into something they can address. I don't think the
latter is necessary for USB devices.

johannes

From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Sep 2010 14:25:47 -0400
Message-ID: <20100927182546.GE11086@tuxdriver.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au>
 <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
 <20100927180412.GD11086@tuxdriver.com>
 <20100927.111818.149846920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ohad@wizery.com, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100927.111818.149846920.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 11:18:18AM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 27 Sep 2010 14:04:12 -0400
> 
> > Subject: [PATCH] wl12xx: fix separate-object-folder builds
> > 
> > Make this go away (happens when building with a separate object
> > directory):
> > 
> > Assembler messages:
> > Fatal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.o: No such file or directory
> > drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12xx_get_platform_data':
> > drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
> > drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by earlier errors, bailing out
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> BTW, if this fuglet going to work if the driver is built modular?
> 
> The idea of this things seems to be to allow arch platform code to call
> into it to set things.  Such calls from arch platform code are going
> to be "obj-y"
> 
> So if this is built into the modular driver, I can't see how it
> can work.

Dave is right -- these Kconfig dependencies (or lack thereof) seem
to be wrong.  Seems like the OMAP code needs to select the option
for this code?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

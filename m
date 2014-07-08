From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/3] drivers: expand usage of request_firmware_direct()
Date: Tue, 8 Jul 2014 15:25:36 -0700
Message-ID: <20140708222536.GA7745@kroah.com>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com>
 <s5hmwczve4i.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	chunkeey@googlemail.com, leedom@chelsio.com, cocci@systeme.lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <s5hmwczve4i.wl%tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 26, 2014 at 06:18:05PM +0200, Takashi Iwai wrote:
> At Tue, 24 Jun 2014 15:39:40 -0700,
> Luis R. Rodriguez wrote:
> > 
> > From: "Luis R. Rodriguez" <mcgrof@suse.com>
> > 
> > Takashi added request_firmware_direct() via bba3a87e9 through v3.14-rc1
> > which avoids the unnecessary delay introduced by using the udev firmware
> > loader in case the first try failed when loading we know loading "firmware"
> > is optional. The first use case was for microcode update but if drivers are
> > using it for optional configuration updates, custom EEPROMs, and other
> > junk other than firmware that should apply as well as good use cases,
> > specially if the driver already had a first phase in which it loaded
> > the first required firmware. While reviewing one driver I figured it'd
> > be best to try to give formalizing a check with SmPL. This isn't perfect
> > it had 1 false possitive drivers/fmc/fmc-fakedev.c on the entire kernel
> > run but my hope is this can be extended a bit more to build more
> > confidence, and then perhaps stuff it as a coccicheck.
> > 
> > I suppose this will not be required once and if we remove
> > CONFIG_FW_LOADER_USER_HELPER. Is that ever going away for good? I know
> > there was a recent attempt to remove the udev loader support but
> > it was unclear if the special alternative helper support would be
> > removed upstream from the kernel.
> 
> Actually a few weeks ago I sent a patch to make request_firmware()
> with usermode helper explicitly to be used by some drivers (like
> dell-rbu).  I hope Greg took it for 3.17.  Once when this patch is in,
> distros can turn off the usermode helper fallback gracefully, so no
> ugly timeout issue shouldn't happen.

That patch is now merged, so this series should not be needed anymore,
right?

thanks,

greg k-h

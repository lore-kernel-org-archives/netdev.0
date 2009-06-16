From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: Re: WARN_ON's in i915_gem_tiling.c
Date: Tue, 16 Jun 2009 09:11:05 +0200
Message-ID: <20090616071105.GA19511@excalibur.local>
References: <20090614173331.18f01123@infradead.org>
	<20090615070651.GB1221@excalibur.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, dri-devel@lists.sourceforge.net, tglx@tglx.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rjw@sisk.pl, eric@anholt.net, akpm@linux-foundation.org,
	dwmw2@infradead.org, torvalds@linux-foundation.org,
	mingo@elte.hu, alan@lxorguk.ukuu.org.uk,
	Arjan van de Ven <arjan@infradead.org>
To: Stefan Schmidt <stefan@datenfreihafen.org>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <20090615070651.GB1221@excalibur.local>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Hello.

Bringing Eric into the loop here as he is listed as author of the
i915_gem_tiling.c

On Mon, 2009-06-15 at 09:06, Stefan Schmidt wrote:
> 
> On Sun, 2009-06-14 at 17:33, Arjan van de Ven wrote:
> > 
> > Rank 1: i915_gem_set_tiling (warning)
> > 	Reported 830 times (3700 total reports)
> > 	[gem] Failure in the tiling code
> > 	This warning was last seen in version 2.6.30, and first seen in 2.6.29-rc2.
> > 	More info: http://www.kerneloops.org/searchweek.php?search=i915_gem_set_tiling
> 
> There seem to be more then one issue. I'm running into one of them here on a
> Lenovo Thinkpad X200s. It's 2.6.30 and I enabled KMS the first time here. So I
> can't tell if it is a regression.
> 
> http://www.kerneloops.org/oops.php?number=207353

http://www.kerneloops.org/raw.php?rawid=453362&msgid=

and

http://www.kerneloops.org/oops.php?number=453361

Are looking similar to #207353 to me. That's the one I can easily reproduce by
booting into an KMS enabled kernel. Without modsetting eveything is fine. Let me
know if there are patches I should give a try.

> The result is that the EDID data could not be read and the wrong screen size
> set:
> [   45.524589] i2c-adapter i2c-3: unable to read EDID block.
> [   45.588200] i915 0000:00:02.0: DVI-D-2: no EDID data
> [   45.777251] [drm] TMDS-14: set mode 1360x768 13
> [   45.777261] [drm] TMDS-16: set mode 1360x768 13 <= Should be 1280x900 here
> 
> Somehow the driver tries to use DVI1 and DVI2 while the display is connected to
> LVDS1.
> 
> stefan@excalibur:~$ xrandr
> Screen 0: minimum 320 x 200, current 1360 x 800, maximum 8192 x 8192
> VGA1 disconnected (normal left inverted right x axis y axis)
> LVDS1 connected 1280x800+0+0 (normal left inverted right x axis y axis) 261mm x
> 163mm
>    1280x800       60.0*+   50.0  
> DVI1 connected 1360x768+0+0 (normal left inverted right x axis y axis) 0mm x 0mm
>    1360x768       59.8* 
>    1152x864       60.0  
>    1024x768       60.0  
>    800x600        60.3  
>    640x480        59.9  
> DVI2 connected 1360x768+0+0 (normal left inverted right x axis y axis) 0mm x 0mm
>    1360x768       59.8* 
>    1152x864       60.0  
>    1024x768       60.0  
>    800x600        60.3  
>    640x480        59.9

regards
Stefan Schmidt

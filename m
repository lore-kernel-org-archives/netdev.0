From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: r8723au: Fix build warnings
Date: Wed, 9 Apr 2014 09:37:35 -0700
Message-ID: <20140409163735.GC16346@kroah.com>
References: <1397055920-11654-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, kbuild-all@01.org,
 Jes Sorensen <Jes.Sorensen@redhat.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1397055920-11654-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 09, 2014 at 10:05:20AM -0500, Larry Finger wrote:
> The kbuild test robot reports the following:
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   75ff24fa52f0cc512ceee4c377632b91a3a80811
> commit: 9176303c404741b2f96796466437f2badf6e289b staging: r8723au: Turn on build of new driver
> date:   4 days ago
> config: make ARCH=avr32 allyesconfig
> 
> All warnings:
> 
> >> drivers/staging/rtl8723au/include/rtw_mlme.h:620: warning: 'rtw_set_roaming' declared inline after being called
>    drivers/staging/rtl8723au/include/rtw_mlme.h:620: warning: previous declaration of 'rtw_set_roaming' was here
> >> drivers/staging/rtl8723au/include/rtw_mlme.h:621: warning: 'rtw_to_roaming' declared inline after being called
>    drivers/staging/rtl8723au/include/rtw_mlme.h:621: warning: previous declaration of 'rtw_to_roaming' was here
> --
>    drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c: In function 'Hal_EEValueCheck':
> >> drivers/staging/rtl8723au/hal/rtl8723a_hal_init.c:2277: warning: comparison is always true due to limited range of data type
> 
> The first two warnings are fixed by making the two prototypes be "inline" to match
> the actual routine. The third warning comes from testing that a u8 quantity is positive.

If the functions are inline, why are they referenced in a .h file at
all?

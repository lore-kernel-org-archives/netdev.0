From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH] e1000: avoid potential deadlock in
 e1000_do_[read|write]_eeprom()
Date: Sat, 11 Jan 2014 03:35:25 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73129684@ORSMSX101.amr.corp.intel.com>
References: <1387578320-26525-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ldv-project@linuxtesting.org" <ldv-project@linuxtesting.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1387578320-26525-1-git-send-email-khoroshilov@ispras.ru>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Alexey Khoroshilov
> Sent: Friday, December 20, 2013 2:25 PM
> To: Kirsher, Jeffrey T
> Cc: Alexey Khoroshilov; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
> Carolyn; Skidmore, Donald C; Rose, Gregory V; Duyck, Alexander H; Ronciak,
> John; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; ldv-project@linuxtesting.org
> Subject: [PATCH] e1000: avoid potential deadlock in
> e1000_do_[read|write]_eeprom()
> 
> If eeprom->word_size is zero, e1000_do_[read|write]_eeprom() invoke
> e1000_init_eeprom_params() to reinit eeprom params.
> That is not a good idea since e1000_init_eeprom_params() calls
> e1000_read_eeprom() if eeprom->type is e1000_eeprom_spi.
> That means a deadlock on e1000_eeprom_lock.
> 
> At the same time it is unclear if the reinit is needed at all.
> e1000_init_eeprom_params() is called from probe, so it should succeed
> before any activities of the module start.
> 
> The patch suggests to remove the try to reinit eeprom params.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
Tested by: Aaron Brown <aaron.f.brown@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000/e1000_hw.c | 8 --------
>  1 file changed, 8 deletions(-)


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

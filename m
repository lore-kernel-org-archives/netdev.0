From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net] driver: e1000: fix race condition between
 e1000_down() and e1000_watchdog
Date: Wed, 11 Oct 2017 01:07:48 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6BE222@ORSMSX101.amr.corp.intel.com>
References: <20170916160000.3560-1-v.maffione@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vincenzo Maffione <v.maffione@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170916160000.3560-1-v.maffione@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Vincenzo Maffione
> Sent: Saturday, September 16, 2017 9:00 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Vincenzo Maffione <v.maffione@gmail.com>
> Subject: [PATCH net] driver: e1000: fix race condition between e1000_down()
> and e1000_watchdog
> 
> This patch fixes a race condition that can result into the interface being
> up and carrier on, but with transmits disabled in the hardware.
> The bug may show up by repeatedly IFF_DOWN+IFF_UP the interface, which
> allows e1000_watchdog() interleave with e1000_down().
> 
>     CPU x                           CPU y
>     --------------------------------------------------------------------
>     e1000_down():
>         netif_carrier_off()
>                                     e1000_watchdog():
>                                         if (carrier == off) {
>                                             netif_carrier_on();
>                                             enable_hw_transmit();
>                                         }
>         disable_hw_transmit();
>                                     e1000_watchdog():
>                                         /* carrier on, do nothing */
> 
> Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

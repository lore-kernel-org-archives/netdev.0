From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] e1000e: x86: e1000 driver trying to free already-free
 irq.
Date: Fri, 28 Oct 2016 02:50:01 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81FBD577@ORSMSX101.amr.corp.intel.com>
References: <20161017165108.29718-5-davsingl@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: khalidm <khalidm@cisco.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Singleton <davsingl@cisco.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017165108.29718-5-davsingl@cisco.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Singleton
> Sent: Monday, October 17, 2016 9:51 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: khalidm <khalidm@cisco.com>; intel-wired-lan@lists.osuosl.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] e1000e: x86: e1000 driver trying to free already-free irq.
> 
> From: khalidm <khalidm@cisco.com>
> 
> During systemd reboot sequence network driver interface is shutdown
> by e1000_close. The PCI driver interface is shut by e1000_shutdown.
> The e1000_shutdown checks for netif_running status, if still up it
> brings down driver. But it disables msi outside of this if statement,
> regardless of netif status. All this is OK when e1000_close happens
> after shutdown. However, by default, everything in systemd is done
> in parallel. This creates a conditions where e1000_shutdown is called
> after e1000_close, therefore hitting BUG_ON assert in free_msi_irqs.
> 
> Cc-Id: xe-kernel@external.cisco.com
> Signed-off-by: khalidm <khalidm@cisco.com>
> Signed-off-by: David Singleton <davsingl@cisco.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

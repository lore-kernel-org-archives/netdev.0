From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v4 3/5] bus: mvebu-bus: Provide inline stub for mvebu_mbus_get_dram_win_info
Date: Fri, 18 Nov 2016 09:32:13 +0100
Message-ID: <87k2c1b33m.fsf@free-electrons.com>
References: <20161117191914.11077-1-f.fainelli@gmail.com>
        <20161117191914.11077-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, mw@semihalf.com,
        arnd@arndb.de, Shaohui.Xie@freescale.com, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34770 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbcKRIc0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 03:32:26 -0500
In-Reply-To: <20161117191914.11077-4-f.fainelli@gmail.com> (Florian Fainelli's
        message of "Thu, 17 Nov 2016 11:19:12 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,
 
 On jeu., nov. 17 2016, Florian Fainelli <f.fainelli@gmail.com> wrote:

> In preparation for allowing CONFIG_MVNETA_BM to build with COMPILE_TEST,
> provide an inline stub for mvebu_mbus_get_dram_win_info().

Actually the set of SoCs supporting mbus is more reduce than MVEBU. You
can have a look on 434cec62a6d7 ("bus: mvebu-mbus: Provide stub function
for mvebu_mbus_get_io_win_info()"), PLAT_ORION seems the good option.


Thanks,

Gregory

>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  include/linux/mbus.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/include/linux/mbus.h b/include/linux/mbus.h
> index 2931aa43dab1..0d3f14fd2621 100644
> --- a/include/linux/mbus.h
> +++ b/include/linux/mbus.h
> @@ -82,6 +82,7 @@ static inline int mvebu_mbus_get_io_win_info(phys_addr_t phyaddr, u32 *size,
>  }
>  #endif
>  
> +#ifdef CONFIG_MVEBU_MBUS
>  int mvebu_mbus_save_cpu_target(u32 __iomem *store_addr);
>  void mvebu_mbus_get_pcie_mem_aperture(struct resource *res);
>  void mvebu_mbus_get_pcie_io_aperture(struct resource *res);
> @@ -97,5 +98,12 @@ int mvebu_mbus_init(const char *soc, phys_addr_t mbus_phys_base,
>  		    size_t mbus_size, phys_addr_t sdram_phys_base,
>  		    size_t sdram_size);
>  int mvebu_mbus_dt_init(bool is_coherent);
> +#else
> +static inline int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target,
> +					       u8 *attr)
> +{
> +	return -EINVAL;
> +}
> +#endif /* CONFIG_MVEBU_MBUS */
>  
>  #endif /* __LINUX_MBUS_H */
> -- 
> 2.9.3
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com

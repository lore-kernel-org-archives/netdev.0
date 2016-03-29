From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] bus: mvebu-mbus: use %pad to print phys_addr_t
Date: Tue, 29 Mar 2016 18:04:47 +0200
Message-ID: <87h9fpw9r4.fsf@free-electrons.com>
References: <1458036233-2770406-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Evan Wang <xswang@marvell.com>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458036233-2770406-1-git-send-email-arnd@arndb.de> (Arnd
	Bergmann's message of "Tue, 15 Mar 2016 11:03:39 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,
 
 On mar., mars 15 2016, Arnd Bergmann <arnd@arndb.de> wrote:

> A recent change to the mbus driver added a warning printk that
> prints a phys_addr_t using the %x format string, which fails in
> case we build with 64-bit phys_addr_t:
>
> drivers/bus/mvebu-mbus.c: In function 'mvebu_mbus_get_dram_win_info':
> drivers/bus/mvebu-mbus.c:975:9: error: format '%x' expects argument of type 'unsigned int', but argument 2 has type 'phys_addr_t {aka long long unsigned int}' [-Werror=format=]
>
> This uses the special %pa format string instead, so we always
> print the correct type.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f2900acea801 ("bus: mvebu-mbus: provide api for obtaining IO
> and DRAM window information")

What is the status of this patch?

Do you plan to send a second version with the title fixed as suggested
by Joe Perches?

Also do you expect that I collect this patch in the mvebu subsystem?

Thanks,

Gregory

> ---
> The warning was introduced in today's linux-next through the net-next
> tree, please apply this fixup on top.
>
>  drivers/bus/mvebu-mbus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/bus/mvebu-mbus.c b/drivers/bus/mvebu-mbus.c
> index c2e52864bb03..ce54a0160faa 100644
> --- a/drivers/bus/mvebu-mbus.c
> +++ b/drivers/bus/mvebu-mbus.c
> @@ -972,7 +972,7 @@ int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target, u8 *attr)
>  		}
>  	}
>  
> -	pr_err("invalid dram address 0x%x\n", phyaddr);
> +	pr_err("invalid dram address %pa\n", &phyaddr);
>  	return -EINVAL;
>  }
>  EXPORT_SYMBOL_GPL(mvebu_mbus_get_dram_win_info);
> -- 
> 2.7.0
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com

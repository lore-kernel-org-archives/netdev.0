From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] drivers/isdn/hisax/Kconfig: Let HISAX_NETJET skip
 microblaze architecture
Date: Mon, 4 Aug 2014 21:23:54 +0200
Message-ID: <20140804212354.74b97cd7@endymion.delvare>
References: <53DFCFC9.6060307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, monstr@monstr.eu
To: Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53DFCFC9.6060307@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chen Gang,

On Tue, 05 Aug 2014 02:24:09 +0800, Chen Gang wrote:
> For HISAX_NETJET, HISAX_NETJET_U or related config needs !__BIG_ENDIAN,
> so skip microblaze, just like skip all other architectures which have
> no CONFIG_*_ENDIAN.
> 
> The related error (with allmodconfig under microblaze):
> 
>     CC [M]  drivers/isdn/hisax/nj_s.o
>   drivers/isdn/hisax/nj_s.c: In function 'setup_netjet_s':
>   drivers/isdn/hisax/nj_s.c:265:2: error: #error "not running on big endian machines now"
>    #error "not running on big endian machines now"
>     ^
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  drivers/isdn/hisax/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
> index 97465ac..eb83d94 100644
> --- a/drivers/isdn/hisax/Kconfig
> +++ b/drivers/isdn/hisax/Kconfig
> @@ -237,7 +237,7 @@ config HISAX_MIC
>  
>  config HISAX_NETJET
>  	bool "NETjet card"
> -	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>  	depends on VIRT_TO_BUS
>  	help
>  	  This enables HiSax support for the NetJet from Traverse
> @@ -249,7 +249,7 @@ config HISAX_NETJET
>  
>  config HISAX_NETJET_U
>  	bool "NETspider U card"
> -	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
> +	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
>  	depends on VIRT_TO_BUS
>  	help
>  	  This enables HiSax support for the Netspider U interface ISDN card

Fine with me, however the list is getting long. It would be better if
we could depend on a functional symbol rather than a negated list of
architectures. Would it make sense to have CONFIG_CPU_LITTLE_ENDIAN
defined on all little-endian architectures, so that driver can depend
on that if needed?

Alternatively, it might make more sense to list the architectures where
these drivers are actually used in practice. I guess that's X86, maybe
ARM and IA64, and that's all?

-- 
Jean Delvare
SUSE L3 Support

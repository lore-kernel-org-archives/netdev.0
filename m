From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 01/10] net: netcp: ethss: add support of
 subsystem register region regmap
Date: Thu, 22 Dec 2016 15:24:09 -0600
Message-ID: <20161222212409.arhurpl4bpqf2yw6@rob-hp-laptop>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
 <1482271793-7671-2-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        grygorii.strashko-l0cyMroinI0@public.gmane.org, mugunthanvnm-l0cyMroinI0@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
To: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1482271793-7671-2-git-send-email-m-karicheri2-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 05:09:44PM -0500, Murali Karicheri wrote:
> From: WingMan Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
> 
> 10gbe phy driver needs to access the 10gbe subsystem control
> register during phy initialization. To facilitate the shared
> access of the subsystem register region between the 10gbe Ethernet
> driver and the phy driver, this patch adds support of the
> subsystem register region defined by a syscon node in the dts.
> 
> Although there is no shared access to the gbe subsystem register
> region, using syscon for that is for the sake of consistency.
> 
> This change is backward compatible with previously released gbe
> devicetree bindings.
> 
> Signed-off-by: WingMan Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
> Signed-off-by: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
> Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
> ---
>  .../devicetree/bindings/net/keystone-netcp.txt     |  16 ++-
>  drivers/net/ethernet/ti/netcp_ethss.c              | 140 +++++++++++++++++----
>  2 files changed, 127 insertions(+), 29 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
> index 04ba1dc..0854a73 100644
> --- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
> +++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
> @@ -72,20 +72,24 @@ Required properties:
>  		"ti,netcp-gbe-2" for 1GbE N NetCP 1.5 (N=2)
>  		"ti,netcp-xgbe" for 10 GbE
>  
> +- syscon-subsys:	phandle to syscon node of the switch
> +			subsystem registers.
> +
>  - reg:		register location and the size for the following register
>  		regions in the specified order.
>  		- switch subsystem registers
> +		- sgmii module registers

This needs to go on the end of the list. Otherwise, it is not backwards 
compatible.

>  		- sgmii port3/4 module registers (only for NetCP 1.4)
>  		- switch module registers
>  		- serdes registers (only for 10G)
>  
>  		NetCP 1.4 ethss, here is the order
> -			index #0 - switch subsystem registers
> +			index #0 - sgmii module registers
>  			index #1 - sgmii port3/4 module registers
>  			index #2 - switch module registers
>  
>  		NetCP 1.5 ethss 9 port, 5 port and 2 port
> -			index #0 - switch subsystem registers
> +			index #0 - sgmii module registers
>  			index #1 - switch module registers
>  			index #2 - serdes registers
>  
> @@ -145,6 +149,11 @@ Optional properties:
>  
>  Example binding:
>  
> +gbe_subsys: subsys@2090000 {
> +	compatible = "syscon";
> +	reg = <0x02090000 0x100>;
> +};
> +
>  netcp: netcp@2000000 {
>  	reg = <0x2620110 0x8>;
>  	reg-names = "efuse";
> @@ -163,7 +172,8 @@ netcp: netcp@2000000 {
>  		ranges;
>  		gbe@90000 {
>  			label = "netcp-gbe";
> -			reg = <0x90000 0x300>, <0x90400 0x400>, <0x90800 0x700>;
> +			syscon-subsys = <&gbe_subsys>;
> +			reg = <0x90100 0x200>, <0x90400 0x200>, <0x90800 0x700>;
>  			/* enable-ale; */
>  			tx-queue = <648>;
>  			tx-channel = <8>;
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

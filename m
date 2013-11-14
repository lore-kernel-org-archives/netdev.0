From: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] of: make of_get_phy_mode parse 'phy-connection-type'
Date: Thu, 14 Nov 2013 16:47:11 +0900
Message-ID: <20131114074711.9A8C5C402E1@trevor.secretlab.ca>
References: <1384386147-13817-1-git-send-email-f.fainelli@gmail.com>
Cc: rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384386147-13817-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Nov 2013 15:42:27 -0800, "Florian Fainelli" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Per the ePAPR v1.1 specification, 'phy-connection-type' is the canonical
> property name for describing an Ethernet to PHY connection type. Make
> sure that of_get_phy_mode() also attempts to parse that property and
> update the comments mentioninng 'phy-mode' to also include
> 'phy-connection-type'.
> 
> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/of/of_net.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
> index 8f9be2e..101a34c 100644
> --- a/drivers/of/of_net.c
> +++ b/drivers/of/of_net.c
> @@ -13,8 +13,8 @@
>  
>  /**
>   * It maps 'enum phy_interface_t' found in include/linux/phy.h
> - * into the device tree binding of 'phy-mode', so that Ethernet
> - * device driver can get phy interface from device tree.
> + * into the device tree binding of 'phy-mode' or 'phy-connection-type',
> + * so that Ethernet device driver can get phy interface from device tree.
>   */
>  static const char *phy_modes[] = {
>  	[PHY_INTERFACE_MODE_NA]		= "",
> @@ -36,8 +36,9 @@ static const char *phy_modes[] = {
>   * of_get_phy_mode - Get phy mode for given device_node
>   * @np:	Pointer to the given device_node
>   *
> - * The function gets phy interface string from property 'phy-mode',
> - * and return its index in phy_modes table, or errno in error case.
> + * The function gets phy interface string from property 'phy-mode' or
> + * 'phy-connection-type', and return its index in phy_modes table, or errno in
> + * error case.
>   */
>  int of_get_phy_mode(struct device_node *np)
>  {
> @@ -45,8 +46,11 @@ int of_get_phy_mode(struct device_node *np)
>  	int err, i;
>  
>  	err = of_property_read_string(np, "phy-mode", &pm);
> -	if (err < 0)
> -		return err;
> +	if (err < 0) {
> +		err = of_property_read_string(np, "phy-connection-type", &pm);
> +		if (err < 0)
> +			return err;
> +	}

Nit: The following would actually be better:
 	err = of_property_read_string(np, "phy-mode", &pm);
+	if (err < 0)
+		err = of_property_read_string(np, "phy-connection-type", &pm);
 	if (err < 0)
 		return err;

Otherwise, the patch looks fine. If you test and repost then it can be merged with my:

Acked-by: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

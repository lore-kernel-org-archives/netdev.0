From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RESEND net-next 5/9] fs_enet: use the new fixed PHY helpers
Date: Thu, 22 May 2014 01:58:12 +0400
Message-ID: <537D2174.8040405@cogentembedded.com>
References: <1400708331-18088-1-git-send-email-f.fainelli@gmail.com> <1400708331-18088-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Vitaly Bordug <vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>,
	Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"open list:OPEN FIRMWARE AND..." <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:LINUX FOR POWERPC..." <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400708331-18088-6-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/22/2014 01:38 AM, Florian Fainelli wrote:

> of_phy_connect_fixed_link() is becoming obsolete, and also required
> platform code to register the fixed PHYs at the specified addresses for
> those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
> plus of_phy_register_fixed_link() helpers to transition over the new
> scheme.

> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 16 +++++++++-------
>   1 file changed, 9 insertions(+), 7 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> index dc80db41d6b3..d602711e00e9 100644
> --- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> +++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
[...]
> @@ -1029,9 +1025,15 @@ static int fs_enet_probe(struct platform_device *ofdev)
>   	fpi->use_napi = 1;
>   	fpi->napi_weight = 17;
>   	fpi->phy_node = of_parse_phandle(ofdev->dev.of_node, "phy-handle", 0);
> -	if ((!fpi->phy_node) && (!of_get_property(ofdev->dev.of_node, "fixed-link",
> -						  NULL)))
> -		goto out_free_fpi;
> +	if (!fpi->phy_node) {
> +		if (of_phy_is_fixed_link(ofdev->dev.of_node)) {

    These two *if* statements could be collapsed, reducing the indentation 
level below.

> +			err = of_phy_register_fixed_link(ofdev->dev.of_node);
> +			if (err)
> +				goto out_free_fpi;
> +
> +			fpi->phy_node = ofdev->dev.of_node;
> +		}
> +	}

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

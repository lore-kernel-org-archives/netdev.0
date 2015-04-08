From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 02/14] ALSA: portman2x4: return proper error values from
 attach
Date: Wed, 08 Apr 2015 16:32:57 +0300
Message-ID: <55252E09.2060600@cogentembedded.com>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com> <1428492040-5581-3-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jean Delvare <jdelvare-l3A5Bk7waGM@public.gmane.org>,
	Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Willy Tarreau <willy-859RlTSWH48dnm+yROfE0A@public.gmane.org>,
	Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428492040-5581-3-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 4/8/2015 2:20 PM, Sudip Mukherjee wrote:

> now that we are monitoring the return value from attach, make the

    So you've first changed the method prototype and follow up with the 
changes to the actual implementations? That's backward. I'm afraid such 
changes can't be done piecemeal.

> required changes to return proper value from its attach function.

> Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
> ---
>   sound/drivers/portman2x4.c | 15 ++++++++++-----
>   1 file changed, 10 insertions(+), 5 deletions(-)

> diff --git a/sound/drivers/portman2x4.c b/sound/drivers/portman2x4.c
> index 464385a..866adbb 100644
> --- a/sound/drivers/portman2x4.c
> +++ b/sound/drivers/portman2x4.c
> @@ -672,32 +672,37 @@ static int snd_portman_probe_port(struct parport *p)
>   	return res ? -EIO : 0;
>   }
>
> -static void snd_portman_attach(struct parport *p)
> +static int snd_portman_attach(struct parport *p)
>   {
>   	struct platform_device *device;
> +	int ret;
>
>   	device = platform_device_alloc(PLATFORM_DRIVER, device_count);
>   	if (!device)
> -		return;
> +		return -ENOMEM;
>
>   	/* Temporary assignment to forward the parport */
>   	platform_set_drvdata(device, p);
>
> -	if (platform_device_add(device) < 0) {
> +	ret = platform_device_add(device);
> +

    I don't think empty line is needed here.

> +	if (ret < 0) {
>   		platform_device_put(device);
> -		return;
> +		return ret;
>   	}
>
[...]

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

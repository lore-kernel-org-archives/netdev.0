From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Re: [PATCH] net:wan:Change location of debug printk statement in the function,hss_hdlc_poll
Date: Thu, 29 Jan 2015 07:35:02 +0100
Message-ID: <m3386uxfft.fsf@t19.piap.pl>
References: <1422143181-4479-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422143181-4479-1-git-send-email-xerofoify@gmail.com> (Nicholas
	Krause's message of "Sat, 24 Jan 2015 18:46:21 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Krause <xerofoify@gmail.com> writes:

> This changes the location of the printk for montioring if the stucture pointer
> desc of type structure desc has a error count due to failing in the switch
> statement for checking it's status from the default switch case in this switch
> to the area of the function for checking if there is a error count. Due to this
> this part of the function can now be uncommented as it's now needed for printing
> out important information if the structure pointer,desc has a error count for
> debugging purposes.

This error count seems to be secondary to the desc->status. It's isn't
normally logged (RX errors on serial links are quite normal) and only
the "default" case, normally not seen, would be logged (to indicate
unhandled condition). In the "normal" error path, the driver ignores
error count, because there could be several errors counted for a single
erroneous frame (or non-frame).

Also the patch seems to remove the beginning of a preprocessor directive
(#if) without removing its end (#endif). I'd be surprised if it compiles.

> --- a/drivers/net/wan/ixp4xx_hss.c
> +++ b/drivers/net/wan/ixp4xx_hss.c
> @@ -697,7 +697,6 @@ static int hss_hdlc_poll(struct napi_struct *napi, int budget)
>  		}
>  
>  		desc = rx_desc_ptr(port, n);
> -#if 0 /* FIXME - error_count counts modulo 256, perhaps we should use it */
>  		if (desc->error_count)
>  			printk(KERN_DEBUG "%s: hss_hdlc_poll status 0x%02X"
>  			       " errors %u\n", dev->name, desc->status,
> @@ -735,9 +734,7 @@ static int hss_hdlc_poll(struct napi_struct *napi, int budget)
>  			dev->stats.rx_length_errors++;
>  			dev->stats.rx_errors++;
>  			break;
> -		default:	/* FIXME - remove printk */
> -			netdev_err(dev, "hss_hdlc_poll: status 0x%02X errors %u\n",
> -				   desc->status, desc->error_count);
> +		default:
>  			dev->stats.rx_errors++;
>  		}

-- 
Krzysztof Halasa

Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland

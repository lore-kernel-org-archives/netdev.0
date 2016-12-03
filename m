From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/1] net: ethernet: 3com: set error code on failures
Date: Sat, 3 Dec 2016 14:53:07 +0100
Message-ID: <06dd8fc8-0c39-e79d-7e34-22bfab17d8a3@gmx.de>
References: <1480771470-6404-1-git-send-email-bianpan201602@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan201602@163.com>,
        David Dillow <dave@thedillows.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480771470-6404-1-git-send-email-bianpan201602@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 03.12.2016 14:24, Pan Bian wrote:
> From: Pan Bian <bianpan2016@163.com>
> 
> In function typhoon_init_one(), returns the value of variable err on
> errors. However, on some error paths, variable err is not set to a
> negative errno. This patch assigns "-EIO" to err on those paths.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

>  
> @@ -2409,6 +2410,7 @@ enum state_values {
>  	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
>  	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
>  		err_msg = "Could not get Sleep Image version";
> +		err = -EIO;
>  		goto error_out_reset;
>  	}
>  
> @@ -2451,6 +2453,7 @@ enum state_values {
>  
>  	if(register_netdev(dev) < 0) {
>  		err_msg = "unable to register netdev";
> +		err = -EIO;
>  		goto error_out_reset;
>  	}
>  
> 

Why not return the error value provided by the called functions? Is there a reason
to map different errors to -EIO?

Regards,
Lino

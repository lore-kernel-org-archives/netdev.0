From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH] hyperv: else branch not necessary
Date: Sun, 25 Jan 2015 18:10:37 +0000
Message-ID: <BY2PR0301MB07114B03CF5BB30D44267412A0340@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1422175610-1924-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicholas Mc Guire <der.herr@hofr.at>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1422175610-1924-1-git-send-email-der.herr@hofr.at>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Nicholas Mc Guire [mailto:der.herr@hofr.at]
> Sent: Sunday, January 25, 2015 12:47 AM
> To: KY Srinivasan
> Cc: Haiyang Zhang; devel@linuxdriverproject.org; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; Nicholas Mc Guire
> Subject: [PATCH] hyperv: else branch not necessary

Make the subject line clear as to  what subsystem this patch is for.

K. Y
> 
> As the if completes with a unconditional goto the else branch is not needed
> here.
> 
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
> ---
> 
> All paths of execution that did not exit through the if branch will go through
> the else branch so no need for an explicit else here
> 
> Patch was compile tested only for x86_64_defconfig + CONFIG_X86_VSMP=y
> CONFIG_HYPERV=m, CONFIG_HYPERV_NET=m
> 
> Patch is against 3.19.0-rc5 -next-20150123
> 
>  drivers/net/hyperv/rndis_filter.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/hyperv/rndis_filter.c
> b/drivers/net/hyperv/rndis_filter.c
> index 7bd8387..efb84a9 100644
> --- a/drivers/net/hyperv/rndis_filter.c
> +++ b/drivers/net/hyperv/rndis_filter.c
> @@ -833,10 +833,10 @@ int rndis_filter_set_packet_filter(struct
> rndis_device *dev, u32 new_filter)
>  		 * send completion for it.
>  		 */
>  		goto exit;
> -	} else {
> -		set_complete = &request-
> >response_msg.msg.set_complete;
> -		status = set_complete->status;
> -	}
> +	}
> +
> +	set_complete = &request->response_msg.msg.set_complete;
> +	status = set_complete->status;
> 
>  cleanup:
>  	if (request)
> --
> 1.7.10.4

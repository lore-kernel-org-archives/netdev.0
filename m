From: Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net] be2net: call napi_disable() for all event queues
Date: Tue, 26 Nov 2013 21:33:37 +0000
Message-ID: <3ecb1939-97c2-4fe6-a437-8f840bec9e89@CMEXHTCAS2.ad.emulex.com>
References: <1385484881-25715-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sathya Perla <Sathya.Perla@Emulex.Com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:11882 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab3KZVdn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 16:33:43 -0500
In-Reply-To: <1385484881-25715-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Tuesday, November 26, 2013 10:55 AM
> To: netdev@vger.kernel.org
> Cc: Sathya Perla; Subramanian Seetharaman; Ajit Khaparde
> Subject: [PATCH net] be2net: call napi_disable() for all event queues
> 
> The recent be2net commit 6384a4d (adds a support for busy polling)
> introduces a regression that results in kernel crash. It incorrectly
> modified be_close() so napi_disable() is called only for the first queue.
> This breaks a correct pairing of napi_enable/_disable for the rest
> of event queues and causes a crash in subsequent be_open() call.
> 
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com>

> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 78a0e85..0aec4d2 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -2663,8 +2663,8 @@ static int be_close(struct net_device *netdev)
>  			napi_disable(&eqo->napi);
>  			be_disable_busy_poll(eqo);
>  		}
> -		adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
>  	}
> +	adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
> 
>  	be_async_mcc_disable(adapter);
> 
> --
> 1.8.3.2

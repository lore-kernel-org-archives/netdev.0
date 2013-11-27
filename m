From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net v2] be2net: call napi_disable() for all event queues
Date: Wed, 27 Nov 2013 10:08:47 +0000
Message-ID: <63828332-e2c9-41f6-a097-5821a974f419@CMEXHTCAS1.ad.emulex.com>
References: <1385539172-4744-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:43728 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465Ab3K0KIx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 05:08:53 -0500
In-Reply-To: <1385539172-4744-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> 
> The recent be2net commit 6384a4d (adds a support for busy polling)
> introduces a regression that results in kernel crash. It incorrectly
> modified be_close() so napi_disable() is called only for the first queue.
> This breaks a correct pairing of napi_enable/_disable for the rest
> of event queues and causes a crash in subsequent be_open() call.
> 
> v2: Applied suggestions from Sathya
> 
> Fixes: 6384a4d ("be2net: add support for ndo_busy_poll")
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Sathya Perla <sathya.perla@emulex.com>

> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 78a0e85..fee64bf 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -2658,8 +2658,8 @@ static int be_close(struct net_device *netdev)
> 
>  	be_roce_dev_close(adapter);
> 
> -	for_all_evt_queues(adapter, eqo, i) {
> -		if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
> +	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
> +		for_all_evt_queues(adapter, eqo, i) {
>  			napi_disable(&eqo->napi);
>  			be_disable_busy_poll(eqo);
>  		}
> --
> 1.8.3.2

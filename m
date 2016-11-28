From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] vxlan: fix a potential issue when create a new vxlan
 fdb entry.
Date: Mon, 28 Nov 2016 12:37:33 +0100
Message-ID: <20161128123733.592c7876@griffin>
References: <1480316543-23298-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58238 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754332AbcK1Lhn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 06:37:43 -0500
In-Reply-To: <1480316543-23298-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2016 15:02:23 +0800, Haishuang Yan wrote:
> vxlan_fdb_append may return error, so add the proper check,
> otherwise it will cause memory leak.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  drivers/net/vxlan.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 21e92be..3b7b237 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -611,6 +611,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
>  	struct vxlan_rdst *rd = NULL;
>  	struct vxlan_fdb *f;
>  	int notify = 0;
> +	int rc = 0;

The initialization to 0 should not be needed. Looks good otherwise.

Thanks,

 Jiri

From: Elad Raz <eladr@mellanox.com>
Subject: Re: [PATCH net-next] switchdev: enforce no pvid flag in vlan ranges
Date: Mon, 12 Oct 2015 12:11:57 +0000
Message-ID: <8D6D3174-F2DB-4BF3-A803-E2E7F26119FF@mellanox.com>
References: <CAE4R7bDCb6DMCYg1j5hHNV-wtgGMEQfeSnOkCiXrJH4LKxuHOA@mail.gmail.com>
 <1444651299-2813-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>,
	"Jiri Pirko" <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0085.outbound.protection.outlook.com ([157.55.234.85]:7344
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751173AbbJLM0Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:26:24 -0400
In-Reply-To: <1444651299-2813-1-git-send-email-razor@blackwall.org>
Content-Language: en-US
Content-ID: <58ECCE53DEAD6D4C8B90F7687FF67F60@eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 12, 2015, at 3:01 PM, Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> We shouldn't allow BRIDGE_VLAN_INFO_PVID flag in VLAN ranges.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> net/switchdev/switchdev.c | 3 +++
> 1 file changed, 3 insertions(+)
> 
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 6e4a4f9ad927..256c596de896 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -720,6 +720,9 @@ static int switchdev_port_br_afspec(struct net_device *dev,
> 			if (vlan.vid_begin)
> 				return -EINVAL;
> 			vlan.vid_begin = vinfo->vid;
> +			/* don't allow range of pvids */
> +			if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
> +				return -EINVAL;
> 		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
> 			if (!vlan.vid_begin)
> 				return -EINVAL;

Acked-by: Elad Raz <eladr@mellanox.com>

> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

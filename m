From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 2/2] net/mlx4_en: Add netdev support for TCP/IP
 offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 17:05:58 +0200
Message-ID: <52B6FFD6.1010105@mellanox.com>
References: <1387720854-1355-1-git-send-email-ogerlitz@mellanox.com>	 <1387720854-1355-3-git-send-email-ogerlitz@mellanox.com>	 <1387721989.22671.16.camel@joe-AO722> <52B6FAED.3070709@mellanox.com> <1387723973.22671.19.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <yanb@mellanox.com>, <ast@plumgrid.com>,
	Matan Barak <matanb@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:39123 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754018Ab3LVPNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 10:13:12 -0500
In-Reply-To: <1387723973.22671.19.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/12/2013 16:52, Joe Perches wrote:
> On Sun, 2013-12-22 at 16:45 +0200, Or Gerlitz wrote:
>> On 22/12/2013 16:19, Joe Perches wrote:
>>> On Sun, 2013-12-22 at 16:00 +0200, Or Gerlitz wrote:
>>> trivia:
> []
>>>> @@ -68,6 +68,12 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
>>>>    	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
>>>>    	if (!(dev->features & NETIF_F_HW_VLAN_CTAG_RX))
>>>>    		context->param3 |= cpu_to_be32(1 << 30);
>>>> +
>>>> +	if (!is_tx && !rss &&
>>>> +	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>>>> +		en_dbg(HW, priv, "Setting RX qp %x tunnel mode to RX tunneled & non-tunneled\n", qpn);
>>>> +		context->srqn |= cpu_to_be32(7 << 28); /* this fills bits 30:28 */
>>> Is that bit setting 0 based or 1 based?
>> 1 based, any issue with that?
> No, but if it's 1 based, doesn't this fill bits 31:29 ?

oops, sorry, I was wrongly reading your question... the setting is 0 
index based, and hence we fill bits 30:28

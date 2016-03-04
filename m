From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/6] net: hns: fixed portid bug in sending manage pkt
Date: Fri, 4 Mar 2016 16:37:19 +0300
Message-ID: <56D98F8F.5010700@cogentembedded.com>
References: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
 <1457053798-93513-4-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com, yankejian@huawei.com
To: Daode Huang <huangdaode@hisilicon.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457053798-93513-4-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/4/2016 4:09 AM, Daode Huang wrote:

> In V2 chip, when sending mamagement packets, the driver should
> config the port id to BD descs.
>
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Signed-off-by: Lisheng <lisheng011@huawei.com>
> ---
>   drivers/net/ethernet/hisilicon/hns/hnae.h         | 3 +++
>   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 1 +
>   drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 4 ++++
>   3 files changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
> index 1cbcb9f..11a3f97 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hnae.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
[...]
> @@ -516,6 +518,7 @@ struct hnae_handle {
>   	int q_num;
>   	int vf_id;
>   	u32 eport_id;
> +	u32 dport_id;	/*v2 tx bd should fill the dport_id*/

    Please add spaces after /* and before */ (like it's done in other places 
in this driver).

[...]
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> index 6250a42..b45dcc2 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -69,6 +69,10 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
>   	hnae_set_bit(rrcfv, HNSV2_TXD_VLD_B, 1);
>   	hnae_set_field(bn_pid, HNSV2_TXD_BUFNUM_M, 0, buf_num - 1);
>
> +	/*fill port_id in the tx bd for sending management pkts*/

    Likewise.

> +	hnae_set_field(bn_pid, HNSV2_TXD_PORTID_M,
> +		       HNSV2_TXD_PORTID_S, ring->q->handle->dport_id);
> +
>   	if (type == DESC_TYPE_SKB) {
>   		skb = (struct sk_buff *)priv;
>

MBR, Sergei

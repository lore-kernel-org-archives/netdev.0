From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCHv2-net-3.8 2/3] qlcnic: set gso_type
Date: Thu, 7 Feb 2013 17:08:29 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E2AB64B@avmb2.qlogic.org>
References: <50a60e1293901965901edb46ae49e52da1d469d5.1360236441.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"eric.dumazet@gma
To: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50a60e1293901965901edb46ae49e52da1d469d5.1360236441.git.mst@redhat.com>
Content-Language: en-US
Content-ID: <D8C730CC2BC9DA4E9BA5BDBA2DAE5D76@qlogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/7/13 5:13 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:

>qlcnic set gso_size but not gso type. This leads to crashes
>in macvtap.
>
>Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>---
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 7 ++++++-
> 1 file changed, 6 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
>index 6f82812..09aa310 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
>@@ -986,8 +986,13 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
> 	th->seq = htonl(seq_number);
> 	length = skb->len;
> 
>-	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
>+	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP) {
> 		skb_shinfo(skb)->gso_size = qlcnic_get_lro_sts_mss(sts_data1);
>+		if (skb->protocol == htons(ETH_P_IPV6))
>+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>+		else
>+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>+	}
> 
> 	if (vid != 0xffff)
> 		__vlan_hwaccel_put_tag(skb, vid);
>-- 
>MST

Thanks!

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

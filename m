From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC 1/1] lro: Generic Large Receive Offload for TCP traffic
Date: Mon, 23 Jul 2007 14:38:32 +0400
Message-ID: <20070723103832.GB22877@2ka.mipt.ru>
References: <200707201741.49290.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>, Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200707201741.49290.ossthema@de.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi Jan-Bernd.

On Fri, Jul 20, 2007 at 05:41:48PM +0200, Jan-Bernd Themann (ossthema@de.ibm.com) wrote:
> Generic LRO patch
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

Besides couple trivial codyng/formatting nits I did not found any
problematic places after review. Details below.

Thanks.

> +#define TCP_PAYLOAD_LENGTH(iph, tcph) \
> +(ntohs(iph->tot_len) - IP_HDR_LEN(iph) - TCP_HDR_LEN(tcph))

A tab?

> +static void lro_add_common(struct net_lro_desc *lro_desc, struct iphdr *iph,
> +			   struct tcphdr *tcph, int tcp_data_len)
> +{
> +	struct sk_buff *parent = lro_desc->parent;
> +	u32 *topt;
> +
> +	lro_desc->pkt_aggr_cnt++;
> +	lro_desc->ip_tot_len += tcp_data_len;
> +	lro_desc->tcp_next_seq += tcp_data_len;
> +	lro_desc->tcp_window = tcph->window;
> +	lro_desc->tcp_ack = tcph->ack_seq;
> +
> +	/* don't update tcp_rcv_tsval, would not work with PAWS */
> +	if (lro_desc->tcp_saw_tstamp) {
> +		topt = (u32 *) (tcph + 1);
> +		lro_desc->tcp_rcv_tsecr = *(topt + 2);
> +	}
> +
> +	parent->len += tcp_data_len;
> +	parent->data_len += tcp_data_len;
> +
> +	lro_desc->data_csum = csum_add(lro_desc->data_csum,
> +				       lro_tcp_data_csum(iph, tcph,
> +							 tcp_data_len));
> +	return;
> +}

return from void? And in other places too.

> +int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
> +		   struct vlan_group *vgrp, u16 vlan_tag, void *priv)
> +{
> +	struct net_lro_desc *lro_desc;
> +        struct iphdr *iph;
> +        struct tcphdr *tcph;
> +	u64 flags;

Broken tab and spaces.

> +struct sk_buff *lro_gen_skb(struct net_lro_mgr *lro_mgr,
> +			    struct skb_frag_struct *frags,
> +			    int len, int true_size,
> +			    void *mac_hdr,
> +			    int hlen)
> +{
> +	struct sk_buff *skb;
> +        struct skb_frag_struct *skb_frags;
> +	int data_len = len;

The same.

> +	skb = netdev_alloc_skb(lro_mgr->dev, hlen);
> +	if (!skb)
> +		return NULL;
> +
> +        skb->len = len;
> +	skb->data_len = len - hlen;

Here too.
There is number of such places, ommitted others.


-- 
	Evgeniy Polyakov

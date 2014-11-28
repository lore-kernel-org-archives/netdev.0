From: nick <xerofoify@gmail.com>
Subject: Fix me in htc.c relating to skb_reserve
Date: Fri, 28 Nov 2014 16:43:18 -0500
Message-ID: <5478EC76.40102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linville@tuxdriver.com, ath10k@lists.infradead.org,
 linux-kernel@vger.kernel.org
To: kvalo@qca.qualcomm.com
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Greetings Kalle, John and others,
I am wondering why this file is complaining about the code below, if someone can explain to me the issue I would be 
very glad :).
 static struct sk_buff *ath10k_htc_build_tx_ctrl_skb(void *ar)
{
       struct sk_buff *skb;
       struct ath10k_skb_cb *skb_cb;

       skb = dev_alloc_skb(ATH10K_HTC_CONTROL_BUFFER_SIZE);
       if (!skb)
               return NULL;

  skb_reserve(skb, 20); /* FIXME: why 20 bytes? */
  WARN_ONCE((unsigned long)skb->data & 3, "unaligned skb");

  skb_cb = ATH10K_SKB_CB(skb);
  memset(skb_cb, 0, sizeof(*skb_cb));

  ath10k_dbg(ar, ATH10K_DBG_HTC, "%s: skb %p\n", __func__, skb);
  return skb;
}

From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Tue, 10 Feb 2015 11:33:48 +0100
Message-ID: <CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	<1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	<1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	<1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	<1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	<1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	<1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	<1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
	<CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
	<1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:45113 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711AbbBJKdt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 05:33:49 -0500
Received: by mail-we0-f170.google.com with SMTP id q59so23827283wes.1
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 02:33:48 -0800 (PST)
In-Reply-To: <1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 February 2015 at 16:11, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Mon, 2015-02-09 at 14:47 +0100, Michal Kazior wrote:
[...]
> This is not what I suggested.
>
> If you test this on any other network device, you'll have
> sk->sk_tx_completion_delay_us =3D=3D 0
>
> amount =3D 0 * (sk->sk_pacing_rate >> 10); --> 0
> limit =3D max(2 * skb->truesize, amount >> 10); --> 2 * skb->truesize

You're right. Sorry for mixing up.


> So non TSO/GSO NIC will not be able to queue more than 2 MSS (one MSS
> per skb)
>
> Then if you store only the last tx completion, you have the possibili=
ty
> of having a last packet of a train (say a retransmit) to make it very
> low.
>
> Ideally the formula would be in TCP something very fast to compute :
>
> amount =3D (sk->sk_pacing_rate >> 10) + sk->tx_completion_delay_cushi=
on;
> limit =3D max(2 * skb->truesize, amount);
> limit =3D min_t(u32, limit, sysctl_tcp_limit_output_bytes);
>
> So a 'problematic' driver would have to do the math (64 bit maths) li=
ke
> this :
>
>
> sk->tx_completion_delay_cushion =3D ewma_tx_delay * sk->sk_pacing_rat=
e;

Hmm. So I've done like you suggested (hopefully I didn't mix anything
up this time around).

I now get pre-regression performance, ~250mbps on 1 flow, 600mbps on 5
flows (vs 250mbps whatever number of flows).


Micha=C5=82


diff --git a/drivers/net/wireless/ath/ath10k/core.c
b/drivers/net/wireless/ath/ath10k/core.c
index 367e896..a29111c 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/firmware.h>
 #include <linux/of.h>
+#include <linux/average.h>

 #include "core.h"
 #include "mac.h"
@@ -1423,6 +1424,7 @@ struct ath10k *ath10k_core_create(size_t
priv_size, struct device *dev,
        init_dummy_netdev(&ar->napi_dev);
        ieee80211_napi_add(ar->hw, &ar->napi, &ar->napi_dev,
                           ath10k_core_napi_dummy_poll, 64);
+       ewma_init(&ar->tx_delay_us, 16384, 8);

        ret =3D ath10k_debug_create(ar);
        if (ret)
diff --git a/drivers/net/wireless/ath/ath10k/core.h
b/drivers/net/wireless/ath/ath10k/core.h
index 3be3a59..34f6d78 100644
--- a/drivers/net/wireless/ath/ath10k/core.h
+++ b/drivers/net/wireless/ath/ath10k/core.h
@@ -24,6 +24,7 @@
 #include <linux/pci.h>
 #include <linux/uuid.h>
 #include <linux/time.h>
+#include <linux/average.h>

 #include "htt.h"
 #include "htc.h"
@@ -82,6 +83,7 @@ struct ath10k_skb_cb {
        dma_addr_t paddr;
        u8 eid;
        u8 vdev_id;
+       ktime_t stamp;

        struct {
                u8 tid;
@@ -625,6 +627,7 @@ struct ath10k {

        struct net_device napi_dev;
        struct napi_struct napi;
+       struct ewma tx_delay_us;

 #ifdef CONFIG_ATH10K_DEBUGFS
        struct ath10k_debug debug;
diff --git a/drivers/net/wireless/ath/ath10k/mac.c
b/drivers/net/wireless/ath/ath10k/mac.c
index 15e47f4..5efb2a7 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -2620,6 +2620,7 @@ static void ath10k_tx(struct ieee80211_hw *hw,
        if (info->flags & IEEE80211_TX_CTL_NO_CCK_RATE)
                ath10k_dbg(ar, ATH10K_DBG_MAC,
"IEEE80211_TX_CTL_NO_CCK_RATE\n");

+       ATH10K_SKB_CB(skb)->stamp =3D ktime_get();
        ATH10K_SKB_CB(skb)->htt.is_offchan =3D false;
        ATH10K_SKB_CB(skb)->htt.tid =3D ath10k_tx_h_get_tid(hdr);
        ATH10K_SKB_CB(skb)->vdev_id =3D ath10k_tx_h_get_vdev_id(ar, vif=
);
diff --git a/drivers/net/wireless/ath/ath10k/txrx.c
b/drivers/net/wireless/ath/ath10k/txrx.c
index 3f00cec..0f5f0f2 100644
--- a/drivers/net/wireless/ath/ath10k/txrx.c
+++ b/drivers/net/wireless/ath/ath10k/txrx.c
@@ -15,6 +15,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */

+#include <net/sock.h>
+#include <linux/average.h>
 #include "core.h"
 #include "txrx.h"
 #include "htt.h"
@@ -82,6 +84,16 @@ void ath10k_txrx_tx_unref(struct ath10k_htt *htt,

        ath10k_report_offchan_tx(htt->ar, msdu);

+       if (msdu->sk) {
+               ewma_add(&ar->tx_delay_us,
+                        ktime_to_ns(ktime_sub(ktime_get(), skb_cb->sta=
mp)) /
+                        NSEC_PER_USEC);
+
+               ACCESS_ONCE(msdu->sk->sk_tx_completion_delay_cushion) =3D
+                               (ewma_read(&ar->tx_delay_us) *
+                                msdu->sk->sk_pacing_rate) >> 20;
+       }
+
        info =3D IEEE80211_SKB_CB(msdu);
        memset(&info->status, 0, sizeof(info->status));
        trace_ath10k_txrx_tx_unref(ar, tx_done->msdu_id);
diff --git a/include/net/sock.h b/include/net/sock.h
index 2210fec..6772543 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -391,6 +391,7 @@ struct sock {
        gfp_t                   sk_allocation;
        u32                     sk_pacing_rate; /* bytes per second */
        u32                     sk_max_pacing_rate;
+       u32                     sk_tx_completion_delay_cushion;
        netdev_features_t       sk_route_caps;
        netdev_features_t       sk_route_nocaps;
        int                     sk_gso_type;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 65caf8b..526a568 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1996,6 +1996,7 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
        max_segs =3D tcp_tso_autosize(sk, mss_now);
        while ((skb =3D tcp_send_head(sk))) {
                unsigned int limit;
+               unsigned int amount;

                tso_segs =3D tcp_init_tso_segs(sk, skb, mss_now);
                BUG_ON(!tso_segs);
@@ -2053,7 +2054,9 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,
                 * of queued bytes to ensure line rate.
                 * One example is wifi aggregation (802.11 AMPDU)
                 */
-               limit =3D max(2 * skb->truesize, sk->sk_pacing_rate >> =
10);
+               amount =3D (sk->sk_pacing_rate >> 10) +
+                        sk->sk_tx_completion_delay_cushion;
+               limit =3D max(2 * skb->truesize, amount);
                limit =3D min_t(u32, limit, sysctl_tcp_limit_output_byt=
es);

                if (atomic_read(&sk->sk_wmem_alloc) > limit) {

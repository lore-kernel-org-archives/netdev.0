From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 21:12:18 +1100
Message-ID: <20060330101218.GA2905@gondor.apana.org.au>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408> <20060329.204409.109404254.davem@davemloft.net> <20060330095245.GA2385@gondor.apana.org.au> <442BAC99.2090404@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Cc: "David S. Miller" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <442BAC99.2090404@kernelpanic.ru>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Mar 30, 2006 at 10:02:01AM +0000, Boris B. Zhmurov wrote:
> 
> [zhmurov@builds linux-2.6.16]$ patch -p1 < 
> ../../../SOURCES/linux-2.6.16-e1000-try-to-fix-assertion_sk_forward_alloc_failed_by_Herbert_Xu.patch 
> 
> patching file drivers/net/e1000/e1000_main.c
> Reversed (or previously applied) patch detected!  Assume -R? [n]
> 
> Herbert, is that patch already included in 2.6.16.1?

Not really.  It's just patch being silly (or too smart :)

Here it is again rediffed against 2.6.16.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="e1000-1.patch"

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 84dcca3..847d168 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2932,13 +2932,6 @@
 		count++;
 #endif
 
-#ifdef NETIF_F_TSO
-	/* Controller Erratum workaround */
-	if (!skb->data_len && tx_ring->last_tx_tso &&
-		!skb_shinfo(skb)->tso_size)
-		count++;
-#endif
-
 	count += TXD_USE_COUNT(len, max_txd_pwr);
 
 	if (adapter->pcix_82544)
@@ -2957,9 +2950,6 @@
 				       max_txd_pwr);
 	if (adapter->pcix_82544)
 		count += nr_frags;
-
-	if (adapter->hw.tx_pkt_filtering && (adapter->hw.mac_type == e1000_82573) )
-		e1000_transfer_dhcp_info(adapter, skb);
 
 	local_irq_save(flags);
 	if (!spin_trylock(&tx_ring->tx_lock)) {
@@ -2967,6 +2957,16 @@
 		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
 	}
+
+#ifdef NETIF_F_TSO
+	/* Controller Erratum workaround */
+	if (!skb->data_len && tx_ring->last_tx_tso &&
+		!skb_shinfo(skb)->tso_size)
+		count++;
+#endif
+
+	if (adapter->hw.tx_pkt_filtering && (adapter->hw.mac_type == e1000_82573) )
+		e1000_transfer_dhcp_info(adapter, skb);
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */

--oyUTqETQ0mS9luUI--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642

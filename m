From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Thu, 22 May 2014 20:57:13 +0200
Message-ID: <537E4889.5000306@pandora.be>
References: <537A6E5C.6090602@pandora.be>	<537C5A6C.3030809@davidnewall.com>	<537CF5A2.3080401@pandora.be> <20140521.161841.1806439174351824310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davidn@davidnewall.com, fw@strlen.de, stephen@networkplumber.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140521.161841.1806439174351824310.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller schreef op 21/05/2014 22:18:
> From: Bart De Schuymer <bdschuym@pandora.be>
>> There's no reason why they should overlap in the cb: it's 48 bytes
>> big, so big enough to hold both struct br_input_skb_cb and struct
>> inet_skb_parm. The original problem was introduced when
>> BR_INPUT_SKB_CB was introduced (around Feb 27, 2010), so fixing
>> BR_INPUT_SKB_CB seems most appropriate to me.
>
> So you are suggesting the patch below will fix everything?

Assuming:
- David Newall's worries about IPCB are incorrect
- you also revert the commit mentioned by David 
(462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge :
Sanitize skb before it enters the IP stack))

Then I give it a good chance the regression will be gone with your patch.

> We never should have added bridging netfilter to the tree in the
> first place, I wish I had better judgment back then.

Feel free to deprecate it. This is my last spare-time involvement.

Please apply following patch:

diff --git a/MAINTAINERS b/MAINTAINERS
index f5de16e..2369bae 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3163,10 +3163,9 @@ S:	Maintained
  F:	drivers/scsi/eata_pio.*

  EBTABLES
-M:	Bart De Schuymer <bart.de.schuymer@pandora.be>
  L:	netfilter-devel@vger.kernel.org
  W:	http://ebtables.sourceforge.net/
-S:	Maintained
+S:	Orphan
  F:	include/linux/netfilter_bridge/ebt_*.h
  F:	include/uapi/linux/netfilter_bridge/ebt_*.h
  F:	net/bridge/netfilter/ebt*.c


From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Wed, 23 Jan 2008 14:42:39 -0200
Message-ID: <47976E7F.80407@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by>	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>	 <1200107027.4477.36.camel@localhost>  <4788FF45.702@bspu.unibel.by>	 <1200253484.4427.33.camel@localhost>  <478B8250.90602@bspu.unibel.by>	 <1200315372.4427.75.camel@localhost>  <478BE021.1070408@bspu.unibel.by> <1200487509.4457.33.camel@localhost>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:50588 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbYAWNv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 08:51:27 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0NCgfXA016075
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 14:42:45 +0200
In-Reply-To: <1200487509.4457.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Too many pixels to smoke. Sorry.

May be so? ;)) (if undefined classid not overwrited by random value tc_classify)
Even "tc" say to classid=0 - "????"

--- 1/net/sched/sch_ingress.c	2008-01-12 17:27:05.000000000 +0200
+++ 2/net/sched/sch_ingress.c	2008-01-22 22:09:32.000000000 +0200
@@ -136,6 +136,9 @@
  	struct ingress_qdisc_data *p = PRIV(sch);
  	struct tcf_result res;
  	int result;
+#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
+	res.classid=0;
+#endif

  	D2PRINTK("ingress_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
  	result = tc_classify(skb, p->filter_list, &res);
@@ -169,6 +172,11 @@
  	sch->bstats.packets++;
  	sch->bstats.bytes += skb->len;
  #endif
+#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
+	if(res.classid)
+	    skb->mark =
(skb->mark&(res.classid>>16))|(skb->tc_index=TC_H_MIN(res.classid));
+//	    skb->mark=res.classid; /* or just so */
+#endif

  	return result;
  }



jamal wrote:

[skipped]

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by


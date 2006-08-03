From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 03 Aug 2006 20:09:07 +0200
Message-ID: <44D23BC3.7040707@arndnet.de>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
 <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
 <20060803151631.GA14774@2ka.mipt.ru> <20060803154125.GA9745@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_0KsYae0UblYfSKytDfHLSw)"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-2.rz.RWTH-Aachen.DE ([134.130.3.131]:53152 "EHLO
	ms-dienst.rz.rwth-aachen.de") by vger.kernel.org with ESMTP
	id S932429AbWHCSJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 14:09:00 -0400
Received: from circe (circe.rz.RWTH-Aachen.DE [134.130.3.36])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0J3F00HJQP2Y9T@ms-dienst.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Aug 2006 20:08:58 +0200 (MEST)
Received: from dustpuppy.kawo2.rwth-aachen.de
 (dustpuppy.kawo2.RWTH-Aachen.DE [134.130.180.5])	by smarthost.rwth-aachen.de
 (8.13.7/8.13.1/1) with ESMTP id k73I8uKf030746	for <netdev@vger.kernel.org>;
 Thu, 03 Aug 2006 20:08:56 +0200
Received: from dustpuppy.kawo2.rwth-aachen.de (localhost [127.0.0.1])
	by dustpuppy.kawo2.rwth-aachen.de (Postfix) with ESMTP id 942D51FC29E	for
 <netdev@vger.kernel.org>; Thu, 03 Aug 2006 20:08:57 +0200 (CEST)
In-reply-to: <20060803154125.GA9745@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_0KsYae0UblYfSKytDfHLSw)
Content-type: text/plain; charset=KOI8-R
Content-transfer-encoding: 7BIT

Evgeniy Polyakov schrieb:
> On Thu, Aug 03, 2006 at 07:16:31PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>>>> then skb_alloc adds a little
>>>> (sizeof(struct skb_shared_info)) at the end, and this ends up
>>>> in 32k request just for 9k jumbo frame.
>>> Strange, why this skb_shared_info cannon be added before first alignment? 
>>> And what about smaller frames like 1500, does this driver behave similar 
>>> (first align then add)?
>> It can be.
>> Could attached  (completely untested) patch help?
> 
> Actually this patch will not help, this new one could.
> 

I applied the attached pachted. And got this output:

> Intel(R) PRO/1000 Network Driver - bufsz 13762
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16058
> Intel(R) PRO/1000 Network Driver - bufsz 15894
> Intel(R) PRO/1000 Network Driver - bufsz 15730
> Intel(R) PRO/1000 Network Driver - bufsz 15566
> Intel(R) PRO/1000 Network Driver - bufsz 15402
> Intel(R) PRO/1000 Network Driver - bufsz 15238
> Intel(R) PRO/1000 Network Driver - bufsz 15074
> Intel(R) PRO/1000 Network Driver - bufsz 14910
> Intel(R) PRO/1000 Network Driver - bufsz 14746
> Intel(R) PRO/1000 Network Driver - bufsz 14582
> Intel(R) PRO/1000 Network Driver - bufsz 14418
> Intel(R) PRO/1000 Network Driver - bufsz 14254
> Intel(R) PRO/1000 Network Driver - bufsz 14090
> Intel(R) PRO/1000 Network Driver - bufsz 13926
> Intel(R) PRO/1000 Network Driver - bufsz 13762
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16058
> Intel(R) PRO/1000 Network Driver - bufsz 15894
> Intel(R) PRO/1000 Network Driver - bufsz 15730
> Intel(R) PRO/1000 Network Driver - bufsz 15566
> Intel(R) PRO/1000 Network Driver - bufsz 15402
> Intel(R) PRO/1000 Network Driver - bufsz 15238
> Intel(R) PRO/1000 Network Driver - bufsz 15074
> Intel(R) PRO/1000 Network Driver - bufsz 14910
> Intel(R) PRO/1000 Network Driver - bufsz 14746
> Intel(R) PRO/1000 Network Driver - bufsz 14582
> Intel(R) PRO/1000 Network Driver - bufsz 14418
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222
> Intel(R) PRO/1000 Network Driver - bufsz 16222

I'm a bit puzzled that there are so much allocations. However the patch
seems to work. (at least not obviously breaks things for me yet)

Best regards
Arnd


--Boundary_(ID_0KsYae0UblYfSKytDfHLSw)
Content-type: text/plain; name=patch.txt
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=patch.txt

--- linux-2.6.17.6/drivers/net/e1000/e1000_main.c	2006-08-03 17:38:53.000000000 +0200
+++ linux-2.6.17.6.patched/drivers/net/e1000/e1000_main.c	2006-08-03 19:38:53.000000000 +0200
@@ -3843,9 +3843,13 @@
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (cleaned_count--) {
-		if (!(skb = buffer_info->skb))
+		if (!(skb = buffer_info->skb)) {
+			if (SKB_DATA_ALIGN(adapter->hw.max_frame_size) + sizeof(struct skb_shared_info) <= bufsz) {
+				bufsz -= sizeof(struct skb_shared_info);
+				printk(KERN_INFO "%s - bufsz %d\n",e1000_driver_string, bufsz);
+			}
 			skb = dev_alloc_skb(bufsz);
-		else {
+		} else {
 			skb_trim(skb, 0);
 			goto map_skb;
 		}

--Boundary_(ID_0KsYae0UblYfSKytDfHLSw)--

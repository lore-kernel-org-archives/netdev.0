From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] Documentation/networking: more accurate LCO explanation
Date: Fri,  6 May 2016 18:57:43 +0300
Message-ID: <1462550263-9742-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Edward Cree <ecree@solarflare.com>, shmulik.ladkani@gmail.com
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33788 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143AbcEFP6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 11:58:04 -0400
Received: by mail-wm0-f67.google.com with SMTP id r12so9425515wme.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 08:58:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In few places the term "ones-complement sum" was used but the actual
meaning is "the complement of the ones-complement sum".

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

 I assume readers interpret the term "ones-complement sum" as the sum
 using one's complement arithmentic, without the final bitwise
 complement of sum's result.
 Hence I added "the complement of" where applicable.

 Documentation/networking/checksum-offloads.txt | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/checksum-offloads.txt b/Documentation/networking/checksum-offloads.txt
index de2a327766..9567200e1f 100644
--- a/Documentation/networking/checksum-offloads.txt
+++ b/Documentation/networking/checksum-offloads.txt
@@ -69,17 +69,17 @@ LCO: Local Checksum Offload
 LCO is a technique for efficiently computing the outer checksum of an
  encapsulated datagram when the inner checksum is due to be offloaded.
 The ones-complement sum of a correctly checksummed TCP or UDP packet is
- equal to the sum of the pseudo header, because everything else gets
- 'cancelled out' by the checksum field.  This is because the sum was
+ equal to the complement of the sum of the pseudo header, because everything
+ else gets 'cancelled out' by the checksum field.  This is because the sum was
  complemented before being written to the checksum field.
 More generally, this holds in any case where the 'IP-style' ones complement
  checksum is used, and thus any checksum that TX Checksum Offload supports.
 That is, if we have set up TX Checksum Offload with a start/offset pair, we
  know that _after the device has filled in that checksum_, the ones
  complement sum from csum_start to the end of the packet will be equal to
- _whatever value we put in the checksum field beforehand_.  This allows us
- to compute the outer checksum without looking at the payload: we simply
- stop summing when we get to csum_start, then add the 16-bit word at
+ the complement of _whatever value we put in the checksum field beforehand_.
+ This allows us to compute the outer checksum without looking at the payload:
+ we simply stop summing when we get to csum_start, then add the 16-bit word at
  (csum_start + csum_offset).
 Then, when the true inner checksum is filled in (either by hardware or by
  skb_checksum_help()), the outer checksum will become correct by virtue of
-- 
2.7.4

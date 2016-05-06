From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2] Documentation/networking: more accurate LCO explanation
Date: Fri,  6 May 2016 20:27:43 +0300
Message-ID: <1462555663-10216-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Edward Cree <ecree@solarflare.com>, shmulik.ladkani@gmail.com
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34168 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758212AbcEFR2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 13:28:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id n129so9759398wmn.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 10:28:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In few places the term "ones-complement sum" was used but the actual
meaning is "the complement of the ones-complement sum".

Also, avoid enclosing long statements with underscore, to ease
readability.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Acked-by: Edward Cree <ecree@solarflare.com>

---
 v2:
  - Fixed one more occurence where "complement of" was missing
  - Got rid of unreadable underscore wrapped statements

 Took the liberty having the underscore removal as part of this patch.
 Let me know if you feel this needs a patch split.

 Documentation/networking/checksum-offloads.txt | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/checksum-offloads.txt b/Documentation/networking/checksum-offloads.txt
index de2a327766..56e3686124 100644
--- a/Documentation/networking/checksum-offloads.txt
+++ b/Documentation/networking/checksum-offloads.txt
@@ -69,18 +69,18 @@ LCO: Local Checksum Offload
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
- know that _after the device has filled in that checksum_, the ones
+ know that after the device has filled in that checksum, the ones
  complement sum from csum_start to the end of the packet will be equal to
- _whatever value we put in the checksum field beforehand_.  This allows us
- to compute the outer checksum without looking at the payload: we simply
- stop summing when we get to csum_start, then add the 16-bit word at
- (csum_start + csum_offset).
+ the complement of whatever value we put in the checksum field beforehand.
+ This allows us to compute the outer checksum without looking at the payload:
+ we simply stop summing when we get to csum_start, then add the complement of
+ the 16-bit word at (csum_start + csum_offset).
 Then, when the true inner checksum is filled in (either by hardware or by
  skb_checksum_help()), the outer checksum will become correct by virtue of
  the arithmetic.
-- 
2.7.4

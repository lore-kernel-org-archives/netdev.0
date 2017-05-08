From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH V2 0/1] net: cdc_ncm: Fix TX zero padding
Date: Mon, 8 May 2017 13:49:56 +0100
Message-ID: <1494247797-1732-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: <jim_baxter@mentor.com>
To: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Analysis
--------

The zero padding that is added to NTB's does not zero
the memory correctly.
This happens because the skb_put called within the memset in
the line:
memset(skb_put(skb_out, ctx->tx_max - skb_out->len),
       0, ctx->tx_max - skb_out->len);
causes the value of skb_out->len to be modified during
the two uses of it within the above line.
This causes non-zeroed data at the end of skb_out.

This issue was found when connecting between an ARM
Sabre SD Host platform and a test box that was
dropping the NDP's due to the non zeroed memory being
identified as an error.

Solution
--------

To resolve this I have cached the value of
ctx->tx_max - skb_out->len before the memset operation.

----

V1: Sent to linux-use for review.
V2: Added netdev mailing list as it was missed for V1.

Jim Baxter (1):
  net: cdc_ncm: Fix TX zero padding

 drivers/net/usb/cdc_ncm.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

-- 
1.9.1

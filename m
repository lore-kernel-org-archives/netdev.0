From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
Subject: [PATCH v3 0/2] Fixes for sierra_net driver
Date: Wed, 8 Feb 2017 02:46:31 +0100
Message-ID: <cad9ab0b146e4391a4c870290450214e@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org>
To: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When trying to initiate a dual-stack (ipv4v6) connection, a MC7710, FW
version SWI9200X_03.05.24.00ap answers with an unsupported LSI. Add support
for this LSI.
Also the link_type should be ignored when going idle, otherwise the modem
is stuck in a bad link state.
Tested on MC7710, T-Mobile DE, APN internet.telekom, IPv4v6 PDP type. Both
IPv4 and IPv6 connections work.

v2: Do not overwrite protocol field in rx_fixup
v3: Remove leftover struct ethhdr *eth declaration

Stefan Brüns (2):
  sierra_net: Add support for IPv6 and Dual-Stack Link Sense Indications
  sierra_net: Skip validating irrelevant fields for IDLE LSIs

 drivers/net/usb/sierra_net.c | 111 +++++++++++++++++++++++++++----------------
 1 file changed, 71 insertions(+), 40 deletions(-)

-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

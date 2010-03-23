From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: [BUG] XFRM IS NOT UPDATING ETH TYPE FIELD FOR INNER PACKET ON ETH
	HEADER
Date: Tue, 23 Mar 2010 10:22:47 -0300
Message-ID: <b7b22e81003230622l7e40c395h126298926a7cb2b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63933 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab0CWNWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 09:22:48 -0400
Received: by wwe15 with SMTP id 15so4065490wwe.19
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 06:22:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Before doing this change wireshark was showing the inner packet as
"malformed" as it uses the ethernet's type field to classify the L3
packets as IPv6, IPv4 and so on.
The problem is when the inner packet is reinserted into Linux stack
and the ethernet header keeps holding on its type field a value for
the protocol of outer packet.

Below my correction on file net/xfrm/xfrm_input.c, function xfrm_prepare_input:

...

skb->protocol = inner_mode->afinfo->eth_proto; // existing code
eth_hdr(skb)->h_proto = skb->protocol; // my change, adding this line

...

Regards,
Eduardo Panisset.

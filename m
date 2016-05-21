From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Missing INET6_PROTO_FINAL in l2tp_ip6_protocol?
Date: Sat, 21 May 2016 15:50:03 +0300
Message-ID: <20160521155003.1410579f@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37081 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcEUMuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 08:50:18 -0400
Received: by mail-wm0-f54.google.com with SMTP id v200so16888384wmv.0
        for <netdev@vger.kernel.org>; Sat, 21 May 2016 05:50:17 -0700 (PDT)
Received: from halley ([5.102.254.121])
        by smtp.gmail.com with ESMTPSA id yr1sm24881492wjc.9.2016.05.21.05.50.15
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 May 2016 05:50:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

inet6_protocol's INET6_PROTO_FINAL flag denotes handler is expected not
to request resubmission for local delivery.

For an INET6_PROTO_FINAL handler, the following actions gets executed
prior delivery, in ip6_input_finish:

			nf_reset(skb);

			skb_postpull_rcsum(skb, skb_network_header(skb),
					   skb_network_header_len(skb));

For some reason, l2tp_ip6_protocol handler is NOT marked as
INET6_PROTO_FINAL. Probably an oversight.

Since 'l2tp_ip6_recv' never results in a resubmission, the above actions
are not applied to skbs passed to l2tp_ip6.

Any reason why l2tp_ip6_protocol should NOT be marked INET6_PROTO_FINAL?

What's the consequences not executing the above actions for l2tp_ip6
packets?

Thanks,
Shmulik

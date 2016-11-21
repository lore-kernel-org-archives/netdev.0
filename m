From: Simon Arlott <simon@fire.lp0.eu>
Subject: [stable 4.4.y] ppp: defer netns reference release for ppp channel
Date: Mon, 21 Nov 2016 21:12:15 +0000
Message-ID: <75ccacc3-a4b4-21ac-aae4-2c8968215738@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tsort.uuid.uk ([81.2.80.87]:43750 "EHLO tsort.uuid.uk"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752077AbcKUVT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 16:19:57 -0500
Received: from redrum.uuid.uk ([2001:8b0:ffea:0:2e0:81ff:fe4d:2bec]:47696 ident=simon)
        by tsort.uuid.uk with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.86_2)
        (envelope-from <simon@fire.lp0.eu>)
        id 1c8vst-0006Y4-SP
        for netdev@vger.kernel.org; Mon, 21 Nov 2016 21:12:15 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply the following patch to linux-stable 4.4.y:

  commit 205e1e255c479f3fd77446415706463b282f94e4
  ppp: defer netns reference release for ppp channel

This is already present in 4.8.y and fixes an issue with ppp channels
that would otherwise cause a BUG() in ppp_pernet while a global ppp
mutex is held, preventing further ppp connections from being
established.

The issue is reproducible by having pppd use a PPPoE server that closes
new connections immediately (e.g. rp-pppoe "pppoe-server -q /bin/true").

-- 
Simon Arlott

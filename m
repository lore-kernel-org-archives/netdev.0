From: Timo Teras <timo.teras@iki.fi>
Subject: Possible regression: "gre: Use inner mac length when computing
 tunnel length"
Date: Thu, 4 Dec 2014 14:16:16 +0200
Message-ID: <20141204141616.185b88c4@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:46780 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbaLDMQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 07:16:22 -0500
Received: by mail-lb0-f181.google.com with SMTP id l4so4424800lbv.26
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 04:16:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After upgrading to latest 3.14.24 or newer, I noticed a weird TSO bug
in the "dmvpn" setup I use. And seems 3.14.23 works just fine. So the
commit 14051f0452a2c26a "gre: Use inner mac length when computing
tunnel length" would appear to be the related commit (but have not yet
tested this).

In practice what happens is that forwarding path between ethX (or vlanX)
and gre1 gets broken.

There's probably two differences to the "regular" gre tunnel case:
- it's nbma mode, meaning the gre header is inserted via slightly
  different code path
- the gre1 packets are IPsec encrypted in transport mode

As additional detail, doing "ethtool -K gre1 tso off" will workaround
the issue, so it is clearly tso issue pointing even further to the
commit in question.

Is this something the suspected patch could cause? Any suggestions
what to test more?

Thanks,
Timo
 

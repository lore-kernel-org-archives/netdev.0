From: Timo Teras <timo.teras@iki.fi>
Subject: request for -stable: "route: Use ipv4_mtu instead of raw rt_pmtu"
Date: Mon, 13 Jul 2015 20:26:54 +0300
Message-ID: <20150713202654.26868008@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Li Wei <lw@cn.fujitsu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33675 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbGMR05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 13:26:57 -0400
Received: by lbbyj8 with SMTP id yj8so44268407lbb.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 10:26:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Can you queue for active older -stables up to 3.18:

commit 3cdaa5be9e81 "ipv4: Don't increase PMTU with Datagram Too Big message"
commit cb6ccf09d6b9 "route: Use ipv4_mtu instead of raw rt_pmtu"

commit 3cdaa5be9e81 made it to 3.19.y and was later fixed additionally
with conversion to ipv4_mtu() in the second referenced commit.

However, these patches together will fix another case that is not so
obvious: the case if the original route had MTU set on it. Previously
it was ignored but using ipv4_mtu as the first check will also check
RTAX_MTU on metrics. This fixes the nasty issue that PMTU can trigger
to send larger packets then what was explicitly configured via a static
route mtu.

Thanks,
Timo

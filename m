From: David Miller <davem@davemloft.net>
Subject: MTU probing bug?
Date: Tue, 25 Jul 2006 00:17:44 -0700 (PDT)
Message-ID: <20060725.001744.26930215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59841
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751386AbWGYHRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 03:17:41 -0400
To: jheffner@psc.edu
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


John, have a look at this code in tcp_write_timeout():

		mss = min(sysctl_tcp_base_mss,
		          tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2);
		mss = max(mss, 68 - tp->tcp_header_len);

That first line looks like it should be a max() instead
of a min().

tcp_base_mss is the smallest MSS we should use, therefore
we should make sure the "mss" is at least that large.

It's also possible that I misread the intention of this code :) From
what I read, it is trying to half the MSS in use and adjust the MTU
search low point to be based upon this new value.


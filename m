From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] route: fib_validate_source remove the <=
 RT_SCOPE_HOST test
Date: Wed, 14 Oct 2015 22:11:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1510142141410.1786@ja.home.ssi.bg>
References: <a9569cddcdeb5f0b7d138a22086f76f1b9e5acd5.1444754404.git.lucien.xin@gmail.com> <alpine.LFD.2.11.1510132223030.2336@ja.home.ssi.bg> <CADvbK_cyMbWCWdRm1CBU6vWQ2MypyP2DSwjdvzEaj1_fy-4vJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	fw@strlen.de
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56835 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752222AbbJNTL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 15:11:59 -0400
In-Reply-To: <CADvbK_cyMbWCWdRm1CBU6vWQ2MypyP2DSwjdvzEaj1_fy-4vJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 15 Oct 2015, lucien xin wrote:

> yeah, I don't understand why err > 0 is necessary to set IPSKB_DOREDIRECT
> to send redirects.
> FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST, what's that mean?

	It tells us that packet comes from remote address that
we can reach directly, without using gateway. The most
common values for nh_scope are RT_SCOPE_LINK (when nh_gw is
unicast address), RT_SCOPE_HOST (when nh_gw is not set or
is local address) and RT_SCOPE_NOWHERE (when we have a
local route). You can check fib_check_nh() and
fib_create_info() for reference.

Regards

--
Julian Anastasov <ja@ssi.bg>

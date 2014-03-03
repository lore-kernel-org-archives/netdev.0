From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] vlan: use ether_addr_equal_64bits to instead
 of ether_addr_equal
Date: Sun, 02 Mar 2014 17:37:42 -0800
Message-ID: <1393810662.13719.43.camel@joe-AO722>
References: <5313D77F.3090508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0068.hostedemail.com ([216.40.44.68]:57066 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751759AbaCCBhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:37:45 -0500
In-Reply-To: <5313D77F.3090508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-03 at 09:14 +0800, Ding Tianhong wrote:
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
> can be used when each argument is an array within a structure that
> contains at least two bytes of data beyond the array, so it is safe
> to use it for vlan.

It's true that ether_addr_equal_64bits is faster for
64 bit architectures.  It's 1 64 bit compare and 1 
48 bit mask instead of a 32 bit and a 16 bit compare.

I think unless the code is _extremely_ performance or
fast-path sensitive, ether_addr_equal should be used.

I believe the vlan_do_receive use qualifies.

Are any of the others on the fast path?

Do you have any performance numbers?

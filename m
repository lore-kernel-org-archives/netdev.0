From: "David S. Miller" <davem@davemloft.net>
Subject: Re: proto_unregister sleeps while atomic
Date: Tue, 06 Sep 2005 16:07:28 -0700 (PDT)
Message-ID: <20050906.160728.25203864.davem@davemloft.net>
References: <200509070026.34999.daniele@orlandi.com>
	<431E1FE9.7030405@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniele@orlandi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751127AbVIFXHd@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <431E1FE9.7030405@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 07 Sep 2005 01:02:01 +0200

> You're right, good catch. This patch fixes it by moving the lock
> down to the list-operation which it is supposed to protect.

I think we need to unlink from the list first if you're
going to do it this way.  Otherwise someone can find the
protocol via lookup, and then bogusly try to use the SLAB
cache we're freeing up.

Or does something else prevent this?

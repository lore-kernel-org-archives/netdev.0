From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Allow a peer to be up at creation time
Date: Thu, 24 Apr 2014 16:42:21 -0400 (EDT)
Message-ID: <20140424.164221.1323078752352256197.davem@davemloft.net>
References: <5358d1a70002df7a00005df100005bf3a00002a40d3b@amlmta037.auone-net.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: slash@ac.auone-net.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5358d1a70002df7a00005df100005bf3a00002a40d3b@amlmta037.auone-net.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Date: Thu, 24 Apr 2014 17:56:06 +0900

> Currently, a veth peer cannot be up at creation time.
> 
> # ip link add type veth peer up
> RTNETLINK answers: Transport endpoint is not connected
> 
> Signed-off-by: Kusanagi Kouichi <slash@ac.auone-net.jp>

I do not think this is sufficient.

There are many problems if you signal an error after we do:

	err = register_netdevice(dev);

For one thing, you aren't unregistering 'dev' in that error path,
furthermore, priv->peer points to the netdevice you are unregistering.

I think this cannot be done, what you aim to achieve, and we just
simply have to live with the current semantics.  Bring the device
up after you have created it.

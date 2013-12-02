From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix transmit queue management
Date: Mon, 02 Dec 2013 08:33:19 -0800
Message-ID: <1386001999.5352.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385631882-12827-2-git-send-email-puzman@gmail.com>
	 <20131129.164229.2292905485668904870.davem@davemloft.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B744F@saturn3.aculab.com>
	 <20131202.111600.1622488165507147936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, puzman@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131202.111600.1622488165507147936.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-02 at 11:16 -0500, David Miller wrote:

> Fragment lists are not to be found in the transmit function of the
> driver.  Any such SKBs will be linearized or similar first.  We do
> want to support them in some capacity in the future, but right now
> we don't.

Right. Such skb are segmented before reaching the driver, unless driver
asserts NETIF_F_FRAGLIST.

So far, only virtual drivers and 2 or 3 others advertise
NETIF_F_FRAGLIST 'support'.

I suspect that the '2 or 3 others' are plain bugs, I'll check this.

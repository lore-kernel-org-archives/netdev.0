From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/5] netfilter: ipset: fix interface comparision in hash-netiface sets
Date: Fri, 29 Jun 2012 16:41:16 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F6E@saturn3.aculab.com>
References: <1340984255-738-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>, <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1340984255-738-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Florian Westphal <fw@strlen.de>
> 
> ifname_compare() assumes that skb->dev is zero-padded,
> e.g 'eth1\0\0\0\0\0...'. This isn't always the case. e1000 driver does
> 
> strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
> 
> in e1000_probe(), so once device is registered dev->name memory
contains
> 'eth1\0:0:3\0\0\0' (or something like that), which makes eth1 compare
fail.

strncpy() would normally zero-fill the destination buffer
(at least the libc version does).

So something else must be wrong.

	David



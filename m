From: Patrick McHardy <kaber@trash.net>
Subject: Re: net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit() functions
Date: Tue, 23 Jun 2009 18:26:36 +0200
Message-ID: <4A41023C.8040000@trash.net>
References: <4A40FCBC.9040700@trash.net> <1245774088.29098.10.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060703030405080706070101"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48071 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbZFWQ0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 12:26:35 -0400
In-Reply-To: <1245774088.29098.10.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060703030405080706070101
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Joe Perches wrote:
> On Tue, 2009-06-23 at 18:03 +0200, Patrick McHardy wrote:
>> This patch is the result of an automatic spatch transformation to
>> convert all ndo_start_xmit() return values of 0 to NETDEV_TX_OK.
> 
> It might be useful if you submitted the spatch source
> that created this transformation.

I would have added it to the changelog, but it includes some workarounds
for false-negatives since the version used in Debian seems to be buggy.
Namely, it didn't manage to find occurences if there was only one, so I
included a number of NOP transformations to work around that. Or maybe
I'm doing something wrong :)

Attached for reference.



--------------060703030405080706070101
Content-Type: text/plain;
 name="netdev.spatch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netdev.spatch"

@ ndomatch @
identifier ndo, xmit;
@@

struct net_device_ops ndo = {
	.ndo_start_xmit		= xmit,
};

@forall@
identifier skb, dev;
identifier ndomatch.xmit;
@@

int xmit(struct sk_buff *skb, struct net_device *dev)
{
...
(
-	return 1;
+	return NETDEV_TX_BUSY;
|
-	return -1;
+	return NETDEV_TX_LOCKED;
|
-	return 0;
+	return NETDEV_TX_OK;
|
-	return NETDEV_TX_BUSY;
+	return NETDEV_TX_BUSY;
|
-	return NETDEV_TX_LOCKED;
+	return NETDEV_TX_LOCKED;
|
-	return NETDEV_TX_OK;
+	return NETDEV_TX_OK;
)
...
}

--------------060703030405080706070101--

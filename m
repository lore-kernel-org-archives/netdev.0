From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 hitting route max_size
Date: Fri, 24 Jun 2011 14:57:58 -0700 (PDT)
Message-ID: <20110624.145758.1438445085852762505.davem@davemloft.net>
References: <20110606231521.GB22559@hostway.ca>
	<20110607.005645.1883989402770213985.davem@davemloft.net>
	<20110609044042.GA32537@hostway.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: sim@hostway.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453Ab1FXV7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 17:59:01 -0400
In-Reply-To: <20110609044042.GA32537@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kirby <sim@hostway.ca>
Date: Wed, 8 Jun 2011 21:40:42 -0700

> Didn't apply to 2.6.39, so I tried 3.0-rc2, but I get an Oops when
> running the example reproduction case I gave before (
> 
> for ((i = 0;i < 4200;i++)); do ip route add unreachable 2000::$i; done
> 
> ) both with and without your patch applied:

I tried to reproduce this with Linus's current tree but I cannot.

Here is what I did:

-------------------- hex.c --------------------
#include <stdio.h>

int main(void)
{
	int i;

	for (i = 0; i < 0x4200; i++) {
		printf("%04x ", i);
	}
	printf("\n");
	return 0;
}
-------------------- hex.c --------------------
bash$ gcc -o hex hex.c
bash$ for i in $(./hex); do ip route add unreachable 2000::$i; done
bash$

It takes a bit of time to run, but no crash. :-)


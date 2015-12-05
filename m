From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 05 Dec 2015 17:27:42 -0500 (EST)
Message-ID: <20151205.172742.1214683922564543621.davem@davemloft.net>
References: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
	<20151205.130313.1952213347830357234.davem@davemloft.net>
	<CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, hannes@stressinduktion.org,
	linville@tuxdriver.com, jesse@kernel.org, anjali.singhai@intel.com,
	netdev@vger.kernel.org, kiran.patil@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbLEW1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 17:27:44 -0500
In-Reply-To: <CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 5 Dec 2015 11:34:47 -0800

> I'm only really interested in what options the customers has in order
> to get this all configured.  As long as there eventually ends up being
> some path forward I'll be good with whatever ends up happening, though
> my preference would be to see some option available in the kernel.

Fair enough.

BTW, I don't entirely buy your hardware complexity argument.

When we're looking at checksumming offload via 1's complement in the
RX descriptor, that is heaps simpler than having a seperate RTL path
for N different encapsulation technologies and/or protocols.

I'd rather maintain a single 1's complement circuit than N header
parser engines that trigger the sum at the right range.

There is definitely long term maintainability and stability value in
this.

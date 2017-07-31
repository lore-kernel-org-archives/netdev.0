From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH v1 5/5] wave: Added basic version of TCP Wave
Date: Mon, 31 Jul 2017 13:39:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD004745C@AcuExch.aculab.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
 <20170728195919.10099-6-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: 'Natale Patriciello' <natale.patriciello@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.194]:60273 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbdGaNjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 09:39:13 -0400
In-Reply-To: <20170728195919.10099-6-natale.patriciello@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Natale Patriciello
> Sent: 28 July 2017 20:59
..
> +static __always_inline bool test_flag(u8 value, const u8 *flags)
> +{
> +	return (*flags & value) == value;
> +}
...
> +	if (!test_flag(FLAG_INIT, &ca->flags))
> +		return;
...

That is a completely unnecessary 'helper'.
It has its arguments in the wrong order.
Doesn't need to pass by reference.
Since you only ever check one bit you don't need the '=='.
Any error seems to be silently ignored.
I bet they can't actually happen at all.

	David

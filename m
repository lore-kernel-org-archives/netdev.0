From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3.12 065/122] lib/checksum.c: fix carry in
 csum_tcpudp_nofold
Date: Tue, 17 Feb 2015 12:04:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE4D1E@AcuExch.aculab.com>
References: <cover.1424099973.git.jslaby@suse.cz>
 <07707a797d6c3cd0bfe86f037d3d1eb329acbc86.1424099973.git.jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	karl beldan <karl.beldan@gmail.com>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: 'Jiri Slaby' <jslaby@suse.cz>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:50013 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbbBQMEw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 07:04:52 -0500
In-Reply-To: <07707a797d6c3cd0bfe86f037d3d1eb329acbc86.1424099973.git.jslaby@suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static inline u32 from64to32(u64 x)
> +{
> +	/* add up 32-bit and 32-bit for 32+c bit */
> +	x = (x & 0xffffffff) + (x >> 32);
> +	/* add up carry.. */
> +	x = (x & 0xffffffff) + (x >> 32);
> +	return (u32)x;
> +}

As a matter of interest, does the compiler optimise away the
second (x & 0xffffffff) ?
The code could just be:
	x = (x & 0xffffffff) + (x >> 32);
	return x + (x >> 32);

	David

	

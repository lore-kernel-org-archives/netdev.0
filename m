From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH net-2.6.25 1/8] Create ipv4_is_<type>(__be32 addr)
 functions
Date: Mon, 17 Dec 2007 23:37:24 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936710AbXLQWh7@vger.kernel.org>
In-Reply-To: <1197589141-7020-1-git-send-email-joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Dec 13 2007 15:38, Joe Perches wrote:
>
>Change IPV4 specific macros LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
>macros to inline functions ipv4_is_<type>(__be32 addr)
>
>Adds type safety and arguably some readability.
>
>Changes since last submission:
>
>Removed ipv4_addr_octets function
>Used hex constants
>Converted recently added rfc3330 macros
>
>Signed-off-by: Joe Perches <joe@perches.com>
>---
>+static inline bool ipv4_is_loopback(__be32 addr)
>+{
>+	return (addr & htonl(0xff000000)) == htonl(0x7f000000);
>+}
>+

Can we use __constant_htonl()?

>+static inline bool ipv4_is_private_10(__be32 addr)
>+{
>+	return (addr & htonl(0xff000000)) == htonl(0x0a000000);
>+}

What are these functions needed for, even? There does not seem to be
any code (at least in davem's net-2.6.25:net/ipv4/, where I dared to grep)
that uses them.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V6 2/4 net-next] skbuff: Add userspace zero-copy
 buffers in skb
Date: Thu, 26 May 2011 22:55:25 +0200
Message-ID: <1306443325.2543.22.camel@edumazet-laptop>
References: <1306438593.5180.33.camel@localhost.localdomain>
	 <1306440247.2543.14.camel@edumazet-laptop>
	 <1306441442.5180.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306441442.5180.51.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 mai 2011 =C3=A0 13:24 -0700, Shirley Ma a =C3=A9crit :

> I could reduce callback pointer by moving it to *arg, but not desc, t=
his
> indicates that which buffer DMA hasn't done yet in *arg.


I guess you dont need to use skb itself to hold all your states ?

I understand its convenient for you, but I believe its worth the pain t=
o
use only one pointer to a (small) object where you put all your stuff.

Some machines alloc/free millions of skbs per second.=20

If/when most skb uses are for userspace zero-copy buffers we can embbed
your small object in skb itself ;)

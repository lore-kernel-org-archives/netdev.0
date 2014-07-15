From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: clean up some sparse endianness warnings in ipv6.h
Date: Tue, 15 Jul 2014 16:05:55 -0700 (PDT)
Message-ID: <20140715.160555.407533257702039786.davem@davemloft.net>
References: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: jlayton@primarydata.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Layton <jlayton@primarydata.com>
Date: Mon, 14 Jul 2014 08:25:46 -0400

>  #endif
> -		(a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0UL;
> +		((a->s6_addr32[2] ^ htonl(0x0000ffff)) == cpu_to_be32(0)));

While you are spinning a new version, change this htonl() to be
cpu_to_be32().  All the rest of this entire expression uses the
cpu_to_*() interfaces, so for consistency this should too.

Thanks.

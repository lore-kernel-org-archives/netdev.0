From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/exthdrs.c et al: Optional strict PadN option
 checking
Date: Thu, 12 Apr 2012 16:00:40 -0400 (EDT)
Message-ID: <20120412.160040.1086391259430365718.davem@davemloft.net>
References: <CABe5r8Kygjg0O21Y5z-F=RRQCqT7ReNya+EohAJU1jauaK536Q@mail.gmail.com>
	<1333811774-3219-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333811774-3219-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sat,  7 Apr 2012 17:16:14 +0200

> Added strict checking of PadN. PadN can be used to increase header
> size and thus push the protocol header into the 2nd fragment.
> 
> PadN is used to align the options within the Hop-by-Hop or
> Destination Options header to 64-bit boundaries. The maximum valid
> size is thus 7 bytes.
> RFC 4942 recommends to actively check the "payload" itself and
> ensure that it contains only zeroes.
> 
> See also RFC 4942 section 2.1.9.5.
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

I think you should do away with the sysctl and always perform these
checks.

At the very leat, the optlen > 7 check should always be performed.
And frankly the pad byte being zero check makes sense to do all the
time as far as I can tell too.

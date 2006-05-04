From: "David S. Miller" <davem@davemloft.net>
Subject: Re: latest -stable breaks Squid
Date: Thu, 04 May 2006 16:25:46 -0700 (PDT)
Message-ID: <20060504.162546.88959729.davem@davemloft.net>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>
	<4459574D.6000303@candelatech.com>
	<cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, herbert@gondor.apana.org.au,
	davej@redhat.com, netdev@vger.kernel.org, stable@vger.kernel.org,
	fedora-list@list.zikzak.de, fedoralist@kotoulas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52654
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932348AbWEDX0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 19:26:09 -0400
To: imcdnzl@gmail.com
In-Reply-To: <cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Thu, 4 May 2006 13:59:04 +1200

> Wouldn't it be more likely commit 5d0b6f2bdaf7e016e750cd24164a241512d968a3
> 
> as this touches net/ipv4/tcp_output.c and is also in same general area?

This commit makes us account transmit memory properly.  Previously we
were underaccounting which is a serious error and in fact could result
in assertion failures due to sk->sk_forward_alloc going negative if
things were just right.

If this change is what makes an application go slower, then the
problem is likely that the socket send buffer limits are not being set
large enough.

That being said, the first thing that should be tried is reverting
the above mentioned change and see if the problem goes away.  If
so, then we need to investigate what the bandwidth delay product is
for the connection, and whether the socket send buffer is set large
enough for that size of pipe.

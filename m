From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 06:22:13 -0700 (PDT)
Message-ID: <20151021.062213.273447452472704627.davem@davemloft.net>
References: <20151021065704.GM7701@secunet.com>
	<20151021105442.GM6948@oracle.com>
	<20151021123628.GP6948@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, dhowells@redhat.com,
	zohar@linux.vnet.ibm.com, David.Woodhouse@intel.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151021123628.GP6948@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 21 Oct 2015 08:36:28 -0400

> +               memcpy((u8 *)p, &tmp, sizeof(tmp));

memcpy() _never_ works for avoiding unaligned accessed.

I repeat, no matter what you do, no matter what kinds of casts or
fancy typing you use, memcpy() _never_ works for this purpose.

The compiler knows that the pointer you are using is supposed to be at
least 8 byte aligned, it can look through the cast and that's
completely legitimate for it to do.

So it can legitimately inline emit loads and stores to implement the
memcpy() and those will still get the unaligned accesses.

There is one and only one portable way to access unaligned data,
and that is with the get_unaligned() and put_unaligned() helpers.

Userland must do something similar to deal with this situation
as well.

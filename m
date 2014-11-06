From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Thu, 6 Nov 2014 06:43:18 +0000
Message-ID: <20141106064318.GW7996@ZenIV.linux.org.uk>
References: <20141105035536.GO7996@ZenIV.linux.org.uk>
 <20141105.155054.2198151263164321219.davem@davemloft.net>
 <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141106055023.GA28865@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141106055023.GA28865@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 01:50:23PM +0800, Herbert Xu wrote:
> +	/* We only need the first two bytes. */
> +	err = memcpy_fromiovecend((void *)&icmph, msg->msg_iov, 0, 2);
> +	if (err)
> +		return err;
> +
> +	fl4->fl4_icmp_type = icmph.type;
> +	fl4->fl4_icmp_code = icmph.code;

That's more readable, but that exposes another problem in there - we read
the same piece of userland data twice, with no promise whatsoever that we'll
get the same value both times...

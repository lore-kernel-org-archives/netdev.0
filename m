From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Uninitialized dst in ip6_dst_lookup
Date: Wed, 21 Jan 2004 22:14:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121221421.11399ba3.davem@redhat.com>
References: <20040119211156.4bff1640.davem@redhat.com>
	<Pine.LNX.4.44.0401201115500.23508-100000@linux-udp15191261uds.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0401201115500.23508-100000@linux-udp15191261uds.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 20 Jan 2004 11:46:02 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> ip6_dst_lookup() is supposed to fill in the *dst, hence it must not
> dereference *dst until it allocates it. However if the passed sk is
> NULL and *dst is not set by the caller, the following code will
> dereference uninitialized memory :
> 
> 	if (*dst == NULL)
> 		*dst = ip6_route_output(sk, fl); >>>>> will not execute
> 	if ((err = (*dst)->error))  >>>>> dereference bad stack address.
> 		goto out_err_release;
> 
> I am suggesting moving the responsibility of ensuring a good *dst from the
> callers to ip6_dst_lookup().

I agree, patch applied.

Thanks.

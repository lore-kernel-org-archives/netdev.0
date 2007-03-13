From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bridge: faster compare for link local addresses
Date: Mon, 12 Mar 2007 17:05:39 -0700
Message-ID: <45F5EAD3.8050501@hp.com>
References: <20070312162015.5d22cd68@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56366 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbXCMAFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 20:05:43 -0400
In-Reply-To: <20070312162015.5d22cd68@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Use logic operations rather than memcmp() to compare destination
> address with link local multicast addresses.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  net/bridge/br_input.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> --- netem-dev.orig/net/bridge/br_input.c
> +++ netem-dev/net/bridge/br_input.c
> @@ -112,7 +112,11 @@ static int br_handle_local_finish(struct
>   */
>  static inline int is_link_local(const unsigned char *dest)
>  {
> -	return memcmp(dest, br_group_address, 5) == 0 && (dest[5] & 0xf0) == 0;
> +	const u16 *a = (const u16 *) dest;
> +	static const u16 *const b = (const u16 *const ) br_group_address;
> +	static const u16 m = __constant_cpu_to_be16(0xfff0);
> +
> +	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
>  }

Being paranoid - are there no worries about the alignment of dest?

rick jones

From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BUG] alignment problem in net/core/flow.c:flow_key_compare
Date: Thu, 18 Mar 2004 18:59:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318185940.45108d6a.akpm@osdl.org>
References: <20040318162903.59192d13.akpm@osdl.org>
	<20040319.115511.32395995.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: davem@redhat.com, netdev@oss.sgi.com, mru@kth.se
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040319.115511.32395995.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org> wrote:
>
>  
>  +#if (BITS_PER_LONG == 64)
>  +#define FLOWI_ALIGN_BYTES 8
>  +#else
>  +#define FLOWI_ALIGN_BYTES 4
>  +#endif
>  +
>   struct flowi {
>   	int	oif;
>   	int	iif;
>  @@ -77,7 +83,7 @@
>   #define fl_icmp_type	uli_u.icmpt.type
>   #define fl_icmp_code	uli_u.icmpt.code
>   #define fl_ipsec_spi	uli_u.spi
>  -};
>  +} __attribute__((__aligned__(FLOWI_ALIGN_BYTES)));
>  

Why not simply

>  +} __attribute__((__aligned__(BITS_PER_LONG/8)));

?

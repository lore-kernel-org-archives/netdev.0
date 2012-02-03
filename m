From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH torvalds/linux.git] Make linux/tcp.h C++ friendly
 (trivial)
Date: Fri, 3 Feb 2012 22:33:32 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1202032232320.25026@pobox.suse.cz>
References: <20111229183002.9B4F4190B09@elbrus2.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Paul Pluzhnikov <ppluzhnikov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49003 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754902Ab2BCVdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 16:33:33 -0500
In-Reply-To: <20111229183002.9B4F4190B09@elbrus2.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Dec 2011, Paul Pluzhnikov wrote:

> Greetings,
> 
> Using linux/tcp.h from C++ results in:
> 
> cat t.cc
> 
> #include <linux/tcp.h>
> int main() { }
> 
> g++ -c t.cc
> 
> In file included from t.cc:1:
> /usr/include/linux/tcp.h:72: error: '__u32 __fswab32(__u32)' cannot appear in a constant-expression
> /usr/include/linux/tcp.h:72: error: a function call cannot appear in a constant-expression
> ...

Paul,

thanks for the patch. I'd however prefer this to go through netdev, not 
feeling like this is fully appropriate for trivial tree.

Adding netdev to CC and keeping the changelog and patch below for 
reference.

> 
> Attached trivial patch fixes this problem.
> 
> Tested: 
> - the t.cc above compiles with g++ and
> - the following program generates the same output before/after
>   the patch:
> 
> #include <linux/tcp.h>
> #include <stdio.h>
> 
> int main ()
> {
> #define P(a) printf("%s: %08x\n", #a, (int)a)
>   P(TCP_FLAG_CWR);
>   P(TCP_FLAG_ECE);
>   P(TCP_FLAG_URG);
>   P(TCP_FLAG_ACK);
>   P(TCP_FLAG_PSH);
>   P(TCP_FLAG_RST);
>   P(TCP_FLAG_SYN);
>   P(TCP_FLAG_FIN);
>   P(TCP_RESERVED_BITS);
>   P(TCP_DATA_OFFSET);
> #undef P
>   return 0;
> }
> 
> Signed-off-by: Paul Pluzhnikov <ppluzhnikov@google.com>
> 
> 
> Thanks,
> 
> P.S. Google has blanket copyright assignment to FSF.
> --
> Paul Pluzhnikov
> 
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7f59ee9..63334f7 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -69,16 +69,16 @@ union tcp_word_hdr {
>  #define tcp_flag_word(tp) ( ((union tcp_word_hdr *)(tp))->words [3]) 
>  
>  enum { 
> -	TCP_FLAG_CWR = __cpu_to_be32(0x00800000),
> -	TCP_FLAG_ECE = __cpu_to_be32(0x00400000),
> -	TCP_FLAG_URG = __cpu_to_be32(0x00200000),
> -	TCP_FLAG_ACK = __cpu_to_be32(0x00100000),
> -	TCP_FLAG_PSH = __cpu_to_be32(0x00080000),
> -	TCP_FLAG_RST = __cpu_to_be32(0x00040000),
> -	TCP_FLAG_SYN = __cpu_to_be32(0x00020000),
> -	TCP_FLAG_FIN = __cpu_to_be32(0x00010000),
> -	TCP_RESERVED_BITS = __cpu_to_be32(0x0F000000),
> -	TCP_DATA_OFFSET = __cpu_to_be32(0xF0000000)
> +	TCP_FLAG_CWR = __constant_cpu_to_be32(0x00800000),
> +	TCP_FLAG_ECE = __constant_cpu_to_be32(0x00400000),
> +	TCP_FLAG_URG = __constant_cpu_to_be32(0x00200000),
> +	TCP_FLAG_ACK = __constant_cpu_to_be32(0x00100000),
> +	TCP_FLAG_PSH = __constant_cpu_to_be32(0x00080000),
> +	TCP_FLAG_RST = __constant_cpu_to_be32(0x00040000),
> +	TCP_FLAG_SYN = __constant_cpu_to_be32(0x00020000),
> +	TCP_FLAG_FIN = __constant_cpu_to_be32(0x00010000),
> +	TCP_RESERVED_BITS = __constant_cpu_to_be32(0x0F000000),
> +	TCP_DATA_OFFSET = __constant_cpu_to_be32(0xF0000000)
>  }; 
>  
>  /*
> 

-- 
Jiri Kosina
SUSE Labs

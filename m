From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Fri, 17 May 2013 16:42:51 -0700
Message-ID: <1368834171.2194.98.camel@joe-AO722>
References: <1368833499.3301.126.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37297 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754338Ab3EQXmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 19:42:52 -0400
In-Reply-To: <1368833499.3301.126.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 16:31 -0700, Eric Dumazet wrote:
> Do not leak starting address of BPF JIT code, as it might help
> intruders to perform an attack.
[]
> diff --git a/include/linux/filter.h b/include/linux/filter.h
[]
> @@ -58,10 +58,11 @@ extern void bpf_jit_free(struct sk_filter *fp);
>  static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
>  				u32 pass, void *image)
>  {
> -	pr_err("flen=%u proglen=%u pass=%u image=%p\n",
> -	       flen, proglen, pass, image);
> +	/* Do not output address (image) for security reason */
> +	pr_err("flen=%u proglen=%u pass=%u image=10\n",
> +	       flen, proglen, pass);

[]

Are stable equivalents for versions before commit 79617801ea0
necessary?

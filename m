From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master] bpf: provide fallback defs for __NR_bpf
 when not avail
Date: Wed, 14 Jun 2017 15:56:48 -0700
Message-ID: <20170614155648.4cfd7a73@xeon-e3>
References: <b59b84be59bccbab994072fdd9969b5d8a483f12.1497480167.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33972 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdFNW44 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 18:56:56 -0400
Received: by mail-pf0-f175.google.com with SMTP id s66so7121131pfs.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 15:56:56 -0700 (PDT)
In-Reply-To: <b59b84be59bccbab994072fdd9969b5d8a483f12.1497480167.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 00:47:15 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> panji reported that he wasn't able to build iproute2's bpf library
> due to lack of __NR_bpf in his system headers. Providing a fallback
> definition when __NR_bpf is not available in the system lets the
> loader compile just fine, so lets add them for majority of archs.
> 
> Reported-by: panji <jpan@live.nl>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  lib/bpf.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/lib/bpf.c b/lib/bpf.c
> index ae4d97d..e1e29cc 100644
> --- a/lib/bpf.c
> +++ b/lib/bpf.c
> @@ -128,6 +128,26 @@ static inline __u64 bpf_ptr_to_u64(const void *ptr)
>  	return (__u64)(unsigned long)ptr;
>  }
>  
> +#ifndef __NR_bpf
> +# if defined(__i386__)
> +#  define __NR_bpf 357
> +# elif defined(__x86_64__)
> +#  define __NR_bpf 321
> +# elif defined(__aarch64__)
> +#  define __NR_bpf 280
> +# elif defined(__sparc__)
> +#  define __NR_bpf 349
> +# elif defined(__arm__)
> +#  define __NR_bpf 386
> +# elif defined(__powerpc__)
> +#  define __NR_bpf 361
> +# elif defined(__s390__)
> +#  define __NR_bpf 351
> +# else
> +#  error __NR_bpf not defined. Update kernel headers.
> +# endif
> +#endif
> +
>  static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
>  {
>  #ifdef __NR_bpf

Sorry this looks like a mess. enumerating architectures in two different
projects is likely to break in future.

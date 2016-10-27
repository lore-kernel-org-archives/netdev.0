From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net] arch/powerpc: Update parameters for csum_tcpudp_magic
 & csum_tcpudp_nofold
Date: Thu, 27 Oct 2016 09:24:08 -0700
Message-ID: <CAKgT0Udqq2nodQceJjneVtE=yLSFT0r5hZKCWMB5dvdSD-G6gw@mail.gmail.com>
References: <1477578606-27562-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <aduyck@mirantis.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33892 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753508AbcJ0QYK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 12:24:10 -0400
Received: by mail-oi0-f68.google.com with SMTP id p136so5353258oic.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 09:24:10 -0700 (PDT)
In-Reply-To: <1477578606-27562-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 7:30 AM, Ivan Vecera <ivecera@redhat.com> wrote:
> Commit 01cfbad "ipv4: Update parameters for csum_tcpudp_magic to their
> original types" changed parameters for csum_tcpudp_magic and
> csum_tcpudp_nofold for many platforms but not for PowerPC.
>
> Fixes: 01cfbad "ipv4: Update parameters for csum_tcpudp_magic to their original types"
> Cc: Alexander Duyck <aduyck@mirantis.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

> ---
>  arch/powerpc/include/asm/checksum.h | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/checksum.h b/arch/powerpc/include/asm/checksum.h
> index ee655ed..1e8fceb 100644
> --- a/arch/powerpc/include/asm/checksum.h
> +++ b/arch/powerpc/include/asm/checksum.h
> @@ -53,10 +53,8 @@ static inline __sum16 csum_fold(__wsum sum)
>         return (__force __sum16)(~((__force u32)sum + tmp) >> 16);
>  }
>
> -static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
> -                                     unsigned short len,
> -                                     unsigned short proto,
> -                                     __wsum sum)
> +static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr, __u32 len,
> +                                       __u8 proto, __wsum sum)
>  {
>  #ifdef __powerpc64__
>         unsigned long s = (__force u32)sum;
> @@ -83,10 +81,8 @@ static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
>   * computes the checksum of the TCP/UDP pseudo-header
>   * returns a 16-bit checksum, already complemented
>   */
> -static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
> -                                       unsigned short len,
> -                                       unsigned short proto,
> -                                       __wsum sum)
> +static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr, __u32 len,
> +                                       __u8 proto, __wsum sum)
>  {
>         return csum_fold(csum_tcpudp_nofold(saddr, daddr, len, proto, sum));
>  }
> --
> 2.7.3
>

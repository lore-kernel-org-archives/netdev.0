From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ipv4: Use BIT macro.
Date: Wed, 29 Mar 2017 13:16:49 -0700
Message-ID: <1490818609.24891.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1490813977.git.rvarsha016@gmail.com>
         <58dc0820.8943620a.67760.546e@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        outreachy-kernel <outreachy-kernel@googlegroups.com>,
        netdev@vger.kernel.org
To: Varsha Rao <rvarsha016@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34957 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932910AbdC2UQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 16:16:52 -0400
Received: by mail-pg0-f65.google.com with SMTP id g2so4436676pge.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 13:16:51 -0700 (PDT)
In-Reply-To: <58dc0820.8943620a.67760.546e@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 00:46 +0530, Varsha Rao wrote:
> Replace bitwise left shift by one operations with BIT() macro. This patch
> fixes the checkpatch issue.
> 
> Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
> ---
>  net/ipv4/tcp_bbr.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
> index 4da4bc1..9f2c869 100644
> --- a/net/ipv4/tcp_bbr.c
> +++ b/net/ipv4/tcp_bbr.c
> @@ -71,10 +71,10 @@
>   * an issue. The upper bound isn't an issue with existing technologies.
>   */
>  #define BW_SCALE 24
> -#define BW_UNIT (1 << BW_SCALE)
> +#define BW_UNIT BIT(BW_SCALE)
>  
>  #define BBR_SCALE 8	/* scaling factor for fractions in BBR (e.g. gains) */
> -#define BBR_UNIT (1 << BBR_SCALE)
> +#define BBR_UNIT BIT(BBR_SCALE)
>  
>  /* BBR has the following modes for deciding how fast to send: */
>  enum bbr_mode {

Well, no.  BIT() is using unsigned long.

#define BIT(nr)    (1UL << (nr))


This change might have unintended effects.

Maybe checkpatch should be fixed.

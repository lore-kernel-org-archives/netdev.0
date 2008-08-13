From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tipc: Use the appropriate swab helper rather than an
 internal helper
Date: Tue, 12 Aug 2008 21:20:17 -0700
Message-ID: <20080812212017.febf1392.akpm@linux-foundation.org>
References: <1218587234.30194.93.camel@brick>
	<20080812205422.4273d598.akpm@linux-foundation.org>
	<1218600348.30194.105.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754258AbYHMEUv@vger.kernel.org>
In-Reply-To: <1218600348.30194.105.camel@brick>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2008 21:05:47 -0700 Harvey Harrison <harvey.harrison@gmail.com> wrote:

> ___generally means I am an internal implementation detail, don't use
> me.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Sorry for breaking the build Andrew, my testing has been with all the __constant
> versions in-tree removed.
> 
>  net/tipc/subscr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
> index 0326d30..f5da05d 100644
> --- a/net/tipc/subscr.c
> +++ b/net/tipc/subscr.c
> @@ -85,7 +85,7 @@ static struct top_srv topsrv = { 0 };
>  
>  static u32 htohl(u32 in, int swap)
>  {
> -	return swap ? (u32)___constant_swab32(in) : in;
> +	return swap ? (u32)swab32(in) : in;
>  }

yes, that's what I did too, only I dropped the
seems-to-me-to-be-unneeded (u32) cast.

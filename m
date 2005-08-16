From: Amin Azez <azez@ufomechanic.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Tue, 16 Aug 2005 12:18:05 +0100
Message-ID: <4301CB6D.80901@ufomechanic.net>
References: <20050811200349.GN5353@rama.de.gnumonks.org>	<42FC0F01.5090802@trash.net>	<20050812115622.GD16325@rama.de.gnumonks.org>
	<42FD4AC6.2020506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42FD4AC6.2020506@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Work well done, so oughtn't div64_64 to go in
include/asm-generic/div64.h one day, to be available kernel wide, as
do_div64_64

I see that net/core/pktgen.c is full of 64 bit division and maybe could
benefit from this, and perhaps a version that does remainders too.

Amin

Patrick McHardy wrote:
> Harald Welte wrote:
> 
>> Just send two incremental patches to Dave.
> 
> 
> Here they are. The first patch fixes the div64_64 function, the second
> one renames some constants.
> 
> 
> ------------------------------------------------------------------------
> 
> [NETFILTER]: Fix div64_64 in ipt_connbytes
> 
> Signded-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
> commit 62084bc1a04e2fbc492566fa30997bd0a7aa2d0a
> tree 083c8042609e0da81f0be9e15583d5d31b54e685
> parent 68e734a5864ba568058c3b8ea63fac3d7d567542
> author Patrick McHardy <kaber@trash.net> Sat, 13 Aug 2005 03:16:32 +0200
> committer Patrick McHardy <kaber@trash.net> Sat, 13 Aug 2005 03:16:32 +0200
> 
>  net/ipv4/netfilter/ipt_connbytes.c |   22 +++++++++-------------
>  1 files changed, 9 insertions(+), 13 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/ipt_connbytes.c b/net/ipv4/netfilter/ipt_connbytes.c
> --- a/net/ipv4/netfilter/ipt_connbytes.c
> +++ b/net/ipv4/netfilter/ipt_connbytes.c
> @@ -22,23 +22,19 @@ MODULE_AUTHOR("Harald Welte <laforge@net
>  MODULE_DESCRIPTION("iptables match for matching number of pkts/bytes per connection");
>  
>  /* 64bit divisor, dividend and result. dynamic precision */
> -static u_int64_t div64_64(u_int64_t divisor, u_int64_t dividend)
> +static u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)

...

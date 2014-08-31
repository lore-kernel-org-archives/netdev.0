From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 7/7] e1000: switch to napi_gro_frags api
Date: Sun, 31 Aug 2014 16:03:12 +0400
Message-ID: <54030F00.3010706@cogentembedded.com>
References: <1409423307-23470-1-git-send-email-fw@strlen.de>
	<1409423307-23470-8-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1409423307-23470-8-git-send-email-fw@strlen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello.

On 8/30/2014 10:28 PM, Florian Westphal wrote:

> napi_gro_frags allows skb re-use in case GRO can merge payload pages
> into an skb on the gro lists.

> netperf TCP_STREAM, kvm-e1000 emulation, mtu 9k:
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> old: 87380  16384  16384    30.00  8985.78
> new: 87380  16384  16384    30.00  9907.05

> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>   drivers/net/ethernet/intel/e1000/e1000_main.c | 50 ++++++++++++++++++---------
>   1 file changed, 33 insertions(+), 17 deletions(-)

> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 9ac9a77..784a67f 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
[...]
> @@ -4234,7 +4234,23 @@ process_skb:
>   					 * buffer_info->rxbuf.page
>   					 */
>   					skb_put(skb, length);
> +					e1000_rx_checksum(adapter,
> +							  (u32)(status) |
> +							  ((u32)(rx_desc->errors) << 24),

    Inner parens are not needed.

[...]

WBR, Sergei


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

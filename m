From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 01/11] net/mlx5e: Single flow order-0
 pages for Striding RQ
Date: Wed, 7 Sep 2016 10:31:33 -0700
Message-ID: <20160907173131.GA64688@ast-mbp.thefacebook.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-2-git-send-email-saeedm@mellanox.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473252152-11379-2-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2016 at 03:42:22PM +0300, Saeed Mahameed wrote:
> From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> To improve the memory consumption scheme, we omit the flow that
> demands and splits high-order pages in Striding RQ, and stay
> with a single Striding RQ flow that uses order-0 pages.
> 
> Moving to fragmented memory allows the use of larger MPWQEs,
> which reduces the number of UMR posts and filler CQEs.
> 
> Moving to a single flow allows several optimizations that improve
> performance, especially in production servers where we would
> anyway fallback to order-0 allocations:
> - inline functions that were called via function pointers.
> - improve the UMR post process.
> 
> This patch alone is expected to give a slight performance reduction.
> However, the new memory scheme gives the possibility to use a page-cache
> of a fair size, that doesn't inflate the memory footprint, which will
> dramatically fix the reduction and even give a huge gain.
> 
> We ran pktgen single-stream benchmarks, with iptables-raw-drop:
> 
> Single stride, 64 bytes:
> * 4,739,057 - baseline
> * 4,749,550 - this patch
> no reduction
> 
> Larger packets, no page cross, 1024 bytes:
> * 3,982,361 - baseline
> * 3,845,682 - this patch
> 3.5% reduction
> 
> Larger packets, every 3rd packet crosses a page, 1500 bytes:
> * 3,731,189 - baseline
> * 3,579,414 - this patch
> 4% reduction

imo it's not a realistic use case, but would be good to mention that
patch 3 brings performance back for this use case anyway.

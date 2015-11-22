From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2 iptables] libxt_cgroup: prepare for multi revisions
Date: Sun, 22 Nov 2015 21:31:28 +0100
Message-ID: <20151122203128.GA3029@salvia>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <20151121161846.GB3428@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, ninasc@fb.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151121161846.GB3428@htj.duckdns.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 21, 2015 at 11:18:46AM -0500, Tejun Heo wrote:
> libxt_cgroup will grow cgroup2 path based match.  Postfix existing
> symbols with _v0 and prepare for multi revision registration.  While
> at it, rename O_CGROUP to O_CLASSID and fwid to classid.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Jan Engelhardt <jengelh@inai.de>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  extensions/libxt_cgroup.c           |   51 +++++++++++++++++++-----------------
>  include/linux/netfilter/xt_cgroup.h |    2 -
>  2 files changed, 28 insertions(+), 25 deletions(-)
> 
> --- a/extensions/libxt_cgroup.c
> +++ b/extensions/libxt_cgroup.c
> @@ -3,30 +3,30 @@
>  #include <linux/netfilter/xt_cgroup.h>
>  
>  enum {
> -	O_CGROUP = 0,
> +	O_CLASSID = 0,
>  };
>  
> -static void cgroup_help(void)
> +static void cgroup_help_v0(void)
>  {
>  	printf(
>  "cgroup match options:\n"
> -"[!] --cgroup fwid  Match cgroup fwid\n");
> +"[!] --cgroup classid            Match cgroup classid\n");

We have to keep the old cgroup integer ID around for a while,
otherwise we'll break users with old kernels and new iptables
utilities.

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sysctl net: Keep tcp_syn_retries inside the boundary
Date: Fri, 19 Jul 2013 18:08:01 +0400
Message-ID: <51E94841.1020202@cogentembedded.com>
References: <1374230873-30070-1-git-send-email-mtesar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michal Tesar <mtesar@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374230873-30070-1-git-send-email-mtesar@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 19-07-2013 14:47, Michal Tesar wrote:

> Limit the min/max value passed to the
> /proc/sys/net/ipv4/tcp_syn_retries.

> Signed-off-by: Michal Tesar <mtesar@redhat.com>
> ---
>   net/ipv4/sysctl_net_ipv4.c |    6 +++++-
>   1 files changed, 5 insertions(+), 1 deletions(-)

> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index b2c123c..fdc2a17 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
[...]
> @@ -332,7 +334,9 @@ static struct ctl_table ipv4_table[] = {
>   		.data		= &sysctl_tcp_syn_retries,
>   		.maxlen		= sizeof(int),
>   		.mode		= 0644,
> -		.proc_handler	= proc_dointvec
> +		.proc_handler	= proc_dointvec_minmax,
> +        .extra1     = &tcp_syn_retries_min,
> +        .extra2     = &tcp_syn_retries_max

    You should indent with tabs, not spaces.

WBR, Sergei

From: Jack Stone <jwjstone@fastmail.fm>
Subject: Re: [PATCH] Documentation/networking/ip-sysctl.txt tcp_tw_recycle
 & tcp_tw_reuse
Date: Wed, 06 Oct 2010 10:09:45 +0100
Message-ID: <4CAC3CD9.9040102@fastmail.fm>
References: <1286213524-4659-1-git-send-email-kerolasa@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Sami Kerola <kerolasa@iki.fi>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1286213524-4659-1-git-send-email-kerolasa@iki.fi>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 On 04/10/2010 18:32, Sami Kerola wrote:
> From: Sami Kerola <kerolasa@iki.fi>
>
> Instead of saying 'consult your technical export' the
> documentation needs to assist an export to decide whether to keep
> these settings off or set them on.
>
> Signed-off-by: Sami Kerola <kerolasa@iki.fi>
I think the idea of this patch is still valuable. I've included possible
rewordings inline below. I can't guarentee the english is correct but
hopefully we can iterate to something acceptable to all.
> ---
>  Documentation/networking/ip-sysctl.txt |   20 +++++++++++++-------
>  1 files changed, 13 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index f350c69..01e2948 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -444,15 +444,21 @@ tcp_tso_win_divisor - INTEGER
>  	Default: 3
>  
>  tcp_tw_recycle - BOOLEAN
> -	Enable fast recycling TIME-WAIT sockets. Default value is 0.
> -	It should not be changed without advice/request of technical
> -	experts.
> +	Enable fast recycling TIME-WAIT sockets. See also caution
> +	wrote to tcp_tw_reuse. Default value is 0.
Enable fast recycling TIME-WAIT sockets. This option can be dangerous.
See the warning
under tcp_tw-reuse for more information. Default value is 0.
>  
>  tcp_tw_reuse - BOOLEAN
> -	Allow to reuse TIME-WAIT sockets for new connections when it is
> -	safe from protocol viewpoint. Default value is 0.
> -	It should not be changed without advice/request of technical
> -	experts.
> +	Allow to reuse TIME-WAIT sockets for new connections when it is safe
> +	from protocol viewpoint. One should enable also tcp_timestamps when
> +	this is enabled. Default value is 0.
> +
> +	Caution. Both tcp_tw_recycle and tcp_tw_reuse can cause problems. You
> +	should not enable either without being sure about network topology in
> +	between node(s) which are using, or used by, the node(s) where the
> +	parameter is enabled. Connections that go via TCP state aware nodes,
> +	such as firewalls, NAT devices or load balancers may start drop frames
> +	because of the setting. The more there are connections the greater is
> +	the likelyhood you will see this issue.
The above paragraph reads oddly to me. How about:
Neither of these options should be enabled unless the network topology
is known. Connections
that go via TCP state aware nodes, such as firewalls, NAT devices or
load balancers may experience
dropped frames. The larger the number of connections the greater the
likelihood of this issue occuring.
>  
>  tcp_window_scaling - BOOLEAN
>  	Enable window scaling as defined in RFC1323.
Hope this helps,

Jack

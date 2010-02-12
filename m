From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next PATCH v3 3/3] net: TCP thin dupack
Date: Fri, 12 Feb 2010 06:19:31 -0500
Message-ID: <4B753943.2080800@gmail.com>
References: <4B73F31F.9000204@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBK?= =?UTF-8?B?w6RydmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>, Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B73F31F.9000204@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last year, I'm pretty sure I was on record as thinking this is *not* a
good idea.  But at least it now requires a sysctl to turn on, and
should default to off.

Also that naming was a bit dicey.  Now the names are more descriptive,
but the "force" is a bit overkill.

How about:
   NET_TCP_FORCE_THIN_LINEAR_DUPACK -> NET_TCP_THIN_LINEAR_DUPACK
   tcp_force_thin_dupack            -> tcp_thin_linear_dupack
   sysctl_tcp_force_thin_dupack     -> sysctl_tcp_thin_linear_dupack


Andreas Petlund wrote:
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 28e0296..c5a73ab 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -89,6 +89,8 @@ int sysctl_tcp_frto __read_mostly = 2;
>  int sysctl_tcp_frto_response __read_mostly;
>  int sysctl_tcp_nometrics_save __read_mostly;
>  
> +int sysctl_tcp_force_thin_dupack __read_mostly;
> +
>  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;

Where is the sysctl initialized?

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 05/15] connection tracking helper for SLP
Date: Wed, 8 May 2013 04:03:28 +0200
Message-ID: <20130508020328.GA7747@localhost>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
 <1367936303-13386-5-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Jiri Bohac <jbohac@suse.cz>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367936303-13386-5-git-send-email-jslaby@suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 07, 2013 at 04:18:13PM +0200, Jiri Slaby wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> 
> A simple connection tracking helper for SLP. Marks replies to a
> SLP broadcast query as ESTABLISHED to allow them to pass through the
> firewall.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: netfilter-devel@vger.kernel.org
> Cc: netfilter@vger.kernel.org
> Cc: coreteam@netfilter.org
> Cc: netdev@vger.kernel.org
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/Kconfig            |  15 +++++
>  net/netfilter/Makefile           |   1 +
>  net/netfilter/nf_conntrack_slp.c | 131 +++++++++++++++++++++++++++++++++++++++
>  3 files changed, 147 insertions(+)
>  create mode 100644 net/netfilter/nf_conntrack_slp.c
> 
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 56d22ca..ec61b30 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -320,6 +320,21 @@ config NF_CONNTRACK_TFTP
>  
>  	  To compile it as a module, choose M here.  If unsure, say N.
>  
> +config NF_CONNTRACK_SLP
> +	tristate "SLP protocol support"
> +	depends on NF_CONNTRACK
> +	depends on NETFILTER_ADVANCED
> +	help
> +	  SLP queries are sometimes sent as broadcast messages from an
> +	  unprivileged port and responded to with unicast messages to the
> +	  same port. This make them hard to firewall properly because connection
> +	  tracking doesn't deal with broadcasts. This helper tracks locally
> +	  originating broadcast SLP queries and the corresponding
> +	  responses. It relies on correct IP address configuration, specifically
> +	  netmask and broadcast address.

We have the user-space helper infrastructure in the conntrack-tools,
this helper has to go there.

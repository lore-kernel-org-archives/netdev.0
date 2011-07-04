From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] Update description of net.sctp.sctp_rmem and
 net.sctp.sctp_wmem tunables
Date: Mon, 4 Jul 2011 10:54:54 -0400
Message-ID: <20110704145454.GA10310@hmsreliant.think-freely.org>
References: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54903 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974Ab1GDOzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 10:55:11 -0400
Content-Disposition: inline
In-Reply-To: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2011 at 06:08:10PM +1000, Max Matveev wrote:
> sctp does not use second and third ("default" and "max") values
> of sctp_(r|w)mem tunables. The format is the same and tcp_(r|w)mem
> but the meaning is different so make the documentation explicit to
> avoid confusion.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index d3d653a..f37d374 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1465,10 +1465,17 @@ sctp_mem - vector of 3 INTEGERs: min, pressure, max
>  	Default is calculated at boot time from amount of available memory.
>  
>  sctp_rmem - vector of 3 INTEGERs: min, default, max
> -	See tcp_rmem for a description.
> +	Only the first value ("min") is used, "default" and "max" are
> +	ignored and may be removed in the future versions.
> +
Its accurate to say that only the first value is usd currently, but because of
the way this sysctl is contructed (its used by the sysctl_rmem pointer in the
sctp_prot struct, which expects an array of three integers in the commong
__sk_mem_schedule function), we wont' be removing the other two values.  Drop
that bit and its an ack from me.
Neil

> +	min: Minimal size of receive buffer used by SCTP socket.
> +	It is guaranteed to each STCP socket (but not association) even 
> +	under moderate memory pressure.
> +
> +	Default: 1 page
>  
>  sctp_wmem  - vector of 3 INTEGERs: min, default, max
> -	See tcp_wmem for a description.
> +	Currently this tunable has no effect.
>  
>  addr_scope_policy - INTEGER
>  	Control IPv4 address scoping - draft-stewart-tsvwg-sctp-ipv4-00
> -- 
> 1.7.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

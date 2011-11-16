From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ss: report ecnseen
Date: Wed, 16 Nov 2011 09:45:50 -0800
Message-ID: <20111116094550.61b73eee@nehalam.linuxnetplumber.net>
References: <20110916103031.7f22b35f@nehalam.linuxnetplumber.net>
	<20111011165908.0d6ed7de@nehalam.linuxnetplumber.net>
	<1318389501.3686.8.camel@edumazet-laptop>
	<1321419087.32381.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45387 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756975Ab1KPRpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 12:45:53 -0500
In-Reply-To: <1321419087.32381.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2011 05:51:27 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Support ECNSEEN reporting in ss command.
> 
> ESTAB      0      0           10.170.73.123:4900
> 10.170.73.125:51001    uid:501 ino:385994 sk:f31e5f00
>          mem:(r0,w0,f0,t0) ts sack ecn ecnseen bic wscale:8,8 rto:210
> rtt:18.75/15 ato:40 cwnd:10 send 69.9Mbps rcv_space:32768
> 
> "ecn" means TCP session negociated ECN capability (TCP layer) at setup
> time
> 
> "ecnseen" at least one frame with ECT(0) or ECT(1) or ECN (IP layer) was
> received from peer.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/netinet/tcp.h |    1 +
>  misc/ss.c             |    2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/include/netinet/tcp.h b/include/netinet/tcp.h
> index 282b29c..95a4fe6 100644
> --- a/include/netinet/tcp.h
> +++ b/include/netinet/tcp.h
> @@ -172,6 +172,7 @@ enum
>  # define TCPI_OPT_SACK		2
>  # define TCPI_OPT_WSCALE	4
>  # define TCPI_OPT_ECN		8
> +# define TCPI_OPT_ECNSEEN	16

Please use same name as include/linux/tcp.h TCPI_OPT_ECN_SEEN
Also, need to get this to glibc to make it included in standard distro
headers.

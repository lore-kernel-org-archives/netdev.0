From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc_util: fix incorrect bare number process in get_rate.
Date: Wed, 11 Jul 2012 07:51:29 -0700
Message-ID: <20120711075129.4f81eea8@nehalam.linuxnetplumber.net>
References: <4FFD2A42.9080507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35746 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139Ab2GKOvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 10:51:47 -0400
In-Reply-To: <4FFD2A42.9080507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jul 2012 15:24:50 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> 
> As the comment and manpage indicated that the bare number means
> bytes per second, so the division is not needed.
> ---
>  tc/tc_util.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index 926ed08..e8d89c1 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
> @@ -153,7 +153,7 @@ int get_rate(unsigned *rate, const char *str)
>  		return -1;
>  
>  	if (*p == '\0') {
> -		*rate = bps / 8.;	/* assume bytes/sec */
> +		*rate = bps;	/* assume bytes/sec */
>  		return 0;
>  	}
>  
Thanks for finding this. The documentation, code and comment do
all need to be the same!

But changing the code as you propose would break existing usage
by scripts. Instead, the man page and comment need to change
to match the reality of the existing application.

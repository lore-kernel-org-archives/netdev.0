From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] iproute2: configure: Add search path for 64bit
 library.
Date: Mon, 20 Aug 2012 16:30:36 +0100
Message-ID: <1345476636.2659.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120813093323.1506aa83@nehalam.linuxnetplumber.net>
	 <1345426907-4236-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41172 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757031Ab2HTPaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 11:30:39 -0400
In-Reply-To: <1345426907-4236-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 09:41 +0800, Li Wei wrote:
> Use pkg-config to tell us the library path and fallback to search
> old paths if xtables.pc not exists.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Tested-by: Ben Hutchings <bhutchings@solarflare.com>

Works for me on Fedora 16.

You should probably change the subject line, as this doesn't change the
search path but mostly replaces it.

Ben.

> ---
> 
> Changes from v1:
> - use pkg-config as Ben and Stephen suggested.
> 
>  configure |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/configure b/configure
> index a1916de..db7cd6a 100755
> --- a/configure
> +++ b/configure
> @@ -148,7 +148,13 @@ check_ipt()
>  
>  check_ipt_lib_dir()
>  {
> -	IPT_LIB_DIR=""
> +	IPT_LIB_DIR=$(pkg-config --variable=xtlibdir xtables)
> +	if [ -n "$IPT_LIB_DIR" ]; then
> +		echo $IPT_LIB_DIR
> +		echo "IPT_LIB_DIR:=$IPT_LIB_DIR" >> Config
> +		return
> +	fi
> +
>  	for dir in /lib /usr/lib /usr/local/lib
>  	do
>  		for file in $dir/{xtables,iptables}/lib*t_*so ; do

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

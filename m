From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] iproute2: configure: Add search path for 64bit
 library.
Date: Mon, 20 Aug 2012 09:02:34 -0700
Message-ID: <20120820090234.09e4326a@nehalam.linuxnetplumber.net>
References: <20120813093323.1506aa83@nehalam.linuxnetplumber.net>
	<1345426907-4236-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44005 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755469Ab2HTQCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 12:02:51 -0400
In-Reply-To: <1345426907-4236-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Aug 2012 09:41:47 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> Use pkg-config to tell us the library path and fallback to search
> old paths if xtables.pc not exists.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
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

Applied

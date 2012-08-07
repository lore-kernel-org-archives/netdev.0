From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] configure: Add search path for 64bit library.
Date: Tue, 7 Aug 2012 19:15:58 +0100
Message-ID: <1344363358.2688.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344313376-22602-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20580 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756009Ab2HGSQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 14:16:02 -0400
In-Reply-To: <1344313376-22602-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The subject line doesn't say what this is for, but it looks like
iproute2...

On Tue, 2012-08-07 at 12:22 +0800, Li Wei wrote:
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> ---
>  configure |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/configure b/configure
> index 0f4444f..997759c 100755
> --- a/configure
> +++ b/configure
> @@ -149,7 +149,7 @@ check_ipt()
>  check_ipt_lib_dir()
>  {
>  	IPT_LIB_DIR=""
> -	for dir in /lib /usr/lib /usr/local/lib
> +	for dir in /lib /usr/lib /usr/local/lib /lib64 /usr/lib64 /usr/local/lib64
>  	do
>  		for file in $dir/{xtables,iptables}/lib*t_*so ; do
>  			if [ -f $file ]; then

On a bi-arch system, surely the lib64 directories should be preferred to
the lib directories?  And this still leaves multi-arch to be handled.

I think this should be done with pkg-config:

    pkg-config --variable=xtlibdir xtables

possibly with that directory list as a fallback if it's useful to
support iptables library versions that didn't include xtables.pc.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

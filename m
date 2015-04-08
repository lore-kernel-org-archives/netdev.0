From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] configure: add missing INCLUDE to netnsid
 detection
Date: Wed, 8 Apr 2015 22:40:06 +0300
Message-ID: <20150408194006.GA17685@angus-think.lan>
References: <42d42073b18a4cc0aebbc912fcc14788693c0c75.1428522001.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:35445 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbbDHTwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 15:52:13 -0400
Received: by lbbuc2 with SMTP id uc2so71906973lbb.2
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 12:52:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <42d42073b18a4cc0aebbc912fcc14788693c0c75.1428522001.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 08, 2015 at 09:42:00PM +0200, Jiri Benc wrote:
> Fixes: d116ff34145b0 ("ip netns: Fix rtnl error while print netns list")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> The whole check added by d116ff34145b0 is dubious, though. This should be
> a run time check, not a compile time one.
> ---
>  configure | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/configure b/configure
> index 631938e97206..e54f4b6db5e8 100755
> --- a/configure
> +++ b/configure
> @@ -224,7 +224,7 @@ check_netnsid()
>  #include <linux/rtnetlink.h>
>  int test_def = RTM_GETNSID;
>  EOF
> -    $CC -c $TMPDIR/netnsid.c >/dev/null 2>&1
> +    $CC -I$INCLUDE -c $TMPDIR/netnsid.c >/dev/null 2>&1
>      if [ $? -eq 0 ]
>      then
>  	echo "IP_CONFIG_NETNSID:=y" >> Config
> -- 
> 1.8.3.1
> 

Hi,

On 3.18 I get same RTNL error with this fix, I agree that runtime checking
would be better than compile time checking, but how to do it, suppress
RTNL errors ?

Regards,

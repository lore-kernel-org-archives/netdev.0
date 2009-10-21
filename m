From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2 5/8] Allow disabling TCP timestamp options per route
Date: Wed, 21 Oct 2009 15:22:02 -0400
Message-ID: <4ADF5F5A.5090403@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-6-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:48016 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271AbZJUTWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 15:22:04 -0400
Received: by fxm18 with SMTP id 18so8141964fxm.37
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 12:22:07 -0700 (PDT)
In-Reply-To: <1256115421-12714-6-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> Implement querying and acting upon the no timestamp bit in the feature 
> field.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
> Sigend-off-by: Yony Amit <yony@comsleep.com>
> 
> ---
>  include/linux/rtnetlink.h |    2 +-
>  net/ipv4/tcp_input.c      |    3 ++-
>  net/ipv4/tcp_output.c     |    8 ++++++--
>  3 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 9c802a6..2ab8c75 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -378,7 +378,7 @@ enum
>  
>  #define RTAX_FEATURE_ECN	0x00000001
>  #define RTAX_FEATURE_NO_SACK	0x00000002
> -#define RTAX_FEATURE_TIMESTAMP	0x00000004
> +#define RTAX_FEATURE_NO_TSTAMP	0x00000004
>  #define RTAX_FEATURE_ALLFRAG	0x00000008
>  
I just realized that unlike NO_WSCALE, this change assumes removing the
sysctl and defaulting on.  I'm opposed to removing this sysctl, so I'm
opposed to this change.

I'd prefer the ability to both turn on for global default off, and
turn off for global default on.  Shouldn't that be 2 different bits?

Or should this be a toggle?  How do other systems handle it?


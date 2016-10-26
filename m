From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3] iproute2: macvlan: add "source" mode
Date: Wed, 26 Oct 2016 11:11:46 -0700
Message-ID: <20161026111146.702e8559@xeon-e3>
References: <1474830535-12689-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        steweg@gmail.com
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35237 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933846AbcJZSLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 14:11:30 -0400
Received: by mail-pf0-f181.google.com with SMTP id s8so997648pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 11:11:30 -0700 (PDT)
In-Reply-To: <1474830535-12689-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Sep 2016 21:08:55 +0200
Michael Braun <michael-dev@fami-braun.de> wrote:

> Adjusting iproute2 utility to support new macvlan link type mode called
> "source".
> 
> Example of commands that can be applied:
>   ip link add link eth0 name macvlan0 type macvlan mode source
>   ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr del 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr flush
>   ip -details link show dev macvlan0
> 
> Based on previous work of Stefan Gula <steweg@gmail.com>
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> 
> Cc: steweg@gmail.com
> --
> v3: fix coding style, sorry for the noise
> ---
>  include/linux/if_link.h |   2 +
>  ip/iplink_macvlan.c     | 103 ++++++++++++++++++++++++++++++++++++++++++++++--
>  man/man8/ip-link.8.in   |  57 +++++++++++++++++++++++++++
>  3 files changed, 158 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 1feb708..ec5e64e 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -401,6 +401,8 @@ enum macvlan_macaddr_mode {
>  };
>  
>  #define MACVLAN_FLAG_NOPROMISC	1
> +#define MACVLAN_FLAG_UNICAST	2
> +#define MACVLAN_FLAG_UNICAST_ALL	4

These header changes are not in upstream source. Sorry, you have to get the kernel
changes in first. I am backing this out of iproute2

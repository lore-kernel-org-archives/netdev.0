From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [RFC] bridge: add netfilter hook for forwarding 802.1D group
 addresses
Date: Sat, 20 Aug 2011 17:31:04 +0200
Message-ID: <4E4FD338.5080100@pandora.be>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>	<20110812154545.79d8313f@nehalam.ftrdhcpuser.net>	<CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>	<20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>	<CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>	<20110818081019.4b9bb79e@nehalam.ftrdhcpuser.net>	<CAEJpZP2FGhPmTi0+eS+QRhj4y+aqfQHnEUrjmOOLHUay1SuAKg@mail.gmail.com>	<20110818093941.5ebf716b@nehalam.ftrdhcpuser.net>	<20110819022731.GC180151@jupiter.n2.diac24.net> <20110819135810.1a529ab2@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>,
	Nick Carter <ncarter100@gmail.com>,
	Ed Swierk <eswierk@bigswitch.com>, netdev@vger.kernel.org,
	bridge@linux-foundation.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110819135810.1a529ab2@nehalam.ftrdhcpuser.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Op 19/08/2011 22:58, Stephen Hemminger schreef:

> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>
> ---
>   include/linux/netfilter_bridge.h      |    5 ++++-
>   net/bridge/br_input.c                 |   15 ++++++++++++---
>   net/bridge/netfilter/ebtable_filter.c |   18 ++++++++++++++++--
>   3 files changed, 32 insertions(+), 6 deletions(-)
>
> --- a/include/linux/netfilter_bridge.h	2011-08-19 13:11:51.972125670 -0700
> +++ b/include/linux/netfilter_bridge.h	2011-08-19 13:13:36.452130443 -0700
> @@ -22,7 +22,10 @@
>   #define NF_BR_POST_ROUTING	4
>   /* Not really a hook, but used for the ebtables broute table */
>   #define NF_BR_BROUTING		5
> -#define NF_BR_NUMHOOKS		6
> +/* Packets to link local multicast addresses (01-80-C2-00-00-XX) */
> +#define NF_BR_LINK_LOCAL_IN	6
> +
> +#define NF_BR_NUMHOOKS		7
>

You will need to make sure you don't break backwards compatibility with 
the ebtables userspace tool. ebtables.h::struct ebt_replace is a 
structure used for communication between userspace and the kernel. It 
has the member hook_entry defined like this:
struct ebt_entries __user *hook_entry[NF_BR_NUMHOOKS];

cheers,
Bart



-- 
Bart De Schuymer
www.artinalgorithms.be

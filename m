From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/3] sunvnet: generate ICMP PTMUD messages for
 smaller port MTUs
Date: Sat, 13 Sep 2014 23:19:43 +0300
Message-ID: <5414A6DF.1060301@cogentembedded.com>
References: <5413723C.7040607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:51601 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbaIMUQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:16:43 -0400
Received: by mail-wg0-f51.google.com with SMTP id k14so2230018wgh.10
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 13:16:42 -0700 (PDT)
In-Reply-To: <5413723C.7040607@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/13/2014 1:22 AM, David L Stevens wrote:

> This patch sends ICMP and ICMPv6 messages for Path MTU Discovery when a remote
> port MTU is smaller than the device MTU. This allows mixing newer VIO protocol
> devices that support MTU negotiation with older devices that do not on the
> same vswitch. It also allows Linux-Linux LDOMs to use 64K-1 data packets even
> though Solaris vswitch is limited to <16K MTU.

> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> ---
>   drivers/net/ethernet/sun/sunvnet.c |   35 +++++++++++++++++++++++++++++++++++
>   1 files changed, 35 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index b557ec4..1251603 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -17,6 +17,13 @@
>   #include <linux/mutex.h>
>   #include <linux/if_vlan.h>
>   +#if IS_ENABLED(CONFIG_IPV6)

    Patch spoiled as well...

> +#include <linux/icmpv6.h>
> +#endif
> +
> +#include <net/icmp.h>
> +#include <net/route.h>
> +
>   #include <asm/vio.h>
>   #include <asm/ldc.h>

WBR, Sergei

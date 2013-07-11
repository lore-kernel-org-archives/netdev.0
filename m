From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] vxlan fdb replace an existing entry
Date: Thu, 11 Jul 2013 08:56:38 -0700
Message-ID: <20130711085638.75690edf@nehalam.linuxnetplumber.net>
References: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:47022 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab3GKP4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 11:56:42 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so7656075pde.37
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 08:56:42 -0700 (PDT)
In-Reply-To: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jul 2013 12:28:19 +0200
Thomas Richter <tmricht@linux.vnet.ibm.com> wrote:

> Add support to replace an existing entry found in the
> vxlan fdb database. The entry in question is identified
> by its unicast mac address and the destination information
> is changed. If the entry is not found, it is added in the
> forwarding database. This is similar to changing an entry
> in the neighbour table.
> 
> Multicast mac addresses can not be changed with the replace
> option.
> 
> This is useful for virtual machine migration when the
> destination of a target virtual machine changes. The replace
> feature can be used instead of delete followed by add.
> 
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> ---
>  drivers/net/vxlan.c | 40 +++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 39 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 227b54a..17681c6 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -42,7 +42,7 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  
> -#define VXLAN_VERSION	"0.1"
> +#define VXLAN_VERSION	"0.1tmr3"

I am ok with everything but the weird version string.
Just make it 0.2 or 0.1.1 if you need it

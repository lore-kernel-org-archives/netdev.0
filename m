From: jamal <j.hadi123@gmail.com>
Subject: Re: [PATCHv3 net-next 0/7] pktgen IPsec support
Date: Tue, 17 Dec 2013 08:41:22 -0500
Message-ID: <52B05482.7030400@gmail.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com> <52AEF4ED.4020504@mojatatu.com> <52AFB580.5060403@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, steffen.klassert@secunet.com, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:37456 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab3LQNlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 08:41:25 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so8336154iec.33
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 05:41:25 -0800 (PST)
In-Reply-To: <52AFB580.5060403@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/13 21:22, Fan Du wrote:
>
>
> I thought we have reach the consensus on this part in previous discussion
> (http://www.spinics.net/lists/netdev/msg261411.html), This enhancement
> patch didn't change original behavior, nor does remove original 
> implementation.
>

right - thats the agreement. i.e nothing changes by default unless
some pktgen parameter is set.
If someone wants to send using original scheme it should work
as long as they dont set this extra parameter.

> This enhancement expects good encapsulation format for the receiver to
> de-encapsulation.
>

Maybe i missed something - receiver wasnt affected in the discussion.
It was only the sender.

> This is snippets of doc updates I could come up with. Please check if 
> it's ok
> for you.
>
> @@ -108,7 +108,9 @@ Examples:
>                                MPLS_RND, VID_RND, SVID_RND
>                                QUEUE_MAP_RND # queue map random
>                                QUEUE_MAP_CPU # queue map mirrors 
> smp_processor_id()
> +                              IPSEC # Make IPsec encapsulation for 
> packet
>
> + pgset spi SPI_VALUE     Set specific SA used to transform packet.
>
>   pgset "udp_src_min 9"   set UDP source port min, If < udp_src_max, then
>                           cycle through the port range.
> @@ -177,6 +179,18 @@ Note when adding devices to a specific CPU there 
> good idea to also assign
>  /proc/irq/XX/smp_affinity so the TX-interrupts gets bound to the same 
> CPU.
>  as this reduces cache bouncing when freeing skb's.
>
> +Enable IPsec
> +============
> +Default IPsec transformation with ESP encapsulation plus Transport mode
> +could be enabled by simply setting:
> +
> +pgset "flag IPSEC"
> +pgset "flows 1"
> +
> +To avoid breaking existing testbed scripts for using AH type and 
> tunnel mode,
> +user could use "pgset spi SPI_VALUE" to specify which formal of 
> transformation
> +to employ.
> +
>

Thanks. Thats a good starting point. I just realized there's nothing at 
all on
ipsec ;-> Maybe you can add even more extensive info to describe all modes?

cheers,
jamal
>  Current commands and configuration options
>  ==========================================
> @@ -225,6 +239,7 @@ flag
>    UDPDST_RND
>    MACSRC_RND
>    MACDST_RND
> +  IPSEC
>
>  dst_min
>
>

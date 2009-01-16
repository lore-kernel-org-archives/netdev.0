From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [build bug] drivers/net/netxen/netxen_nic_main.c:1189: error:
 implicit declaration of function 'ipv6_hdr'
Date: Fri, 16 Jan 2009 09:54:40 -0800
Message-ID: <4970C9E0.6030702@netxen.com>
References: <20090115.160159.262623707.davem@davemloft.net> <20090116103209.GA9122@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:9740 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S936595AbZAPRyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 12:54:46 -0500
In-Reply-To: <20090116103209.GA9122@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I guess I need to explicitly include <linux/ipv6.h>.
I will follow up with a patch to fix this.

-Dhananjay

Ingo Molnar wrote:
> * David Miller <davem@davemloft.net> wrote:
> 
>>       netxen: fix endianness in firmware commands
>>       netxen: fix ipv6 offload and tx cleanup
>>       netxen: fix link speed reporting for some boards
>>       netxen: firmware init fix
>>       netxen: cleanup mac list on driver unload
>>       netxen: hold tx lock while sending firmware commands
>>       netxen: handle dma mapping failures
> 
> One of these causes frequent build failures on x86, on today's -git:
> 
>  drivers/net/netxen/netxen_nic_main.c:1189: error: implicit declaration of function 'ipv6_hdr'
>  drivers/net/netxen/netxen_nic_main.c:1189: error: invalid type argument of '->'
> 
> i suspect the key aspect is:
> 
> # CONFIG_IPV6 is not set
> 
> 	Ingo

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 0/3] sunvnet: NAPIfy sunvnet
Date: Sat, 25 Oct 2014 16:21:22 -0400 (EDT)
Message-ID: <20141025.162122.1889567772198459311.davem@davemloft.net>
References: <20141025191152.GA31334@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bob.picco@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbaJYUVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 16:21:25 -0400
In-Reply-To: <20141025191152.GA31334@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat, 25 Oct 2014 15:11:52 -0400

> This patchset converts the sunvnet driver to use the NAPI framework.
> Changes since v4 to Patch1: 
>   vnet_event accumulates LDC_EVENT_* bits into rx_event. 
>   vnet_event_napi() unrolls send_events() logic to process all rx_event bits.
> Changes since v5: 
>   Patch 1: use net_device.h definition for NAPI_POLL_WEIGHT.
>   Drop sparclinux changes (patch3) per David Miller feedback 
> 
> Patch 1 in the series addresses the packet-receive path- all
> the vnet_event() processing is moved into NAPI context.
> This patch is dependant on the sparc-next commit:
>   "sparc64: Add vio_set_intr() to enable/disable Rx interrupts"
>   (sparc commit id ca605b7dd740c8909408d67911d8ddd272c2b320)
> 
> Patch 2 uses RCU to fix race conditions between vnet_port_remove and
> paths that access/modify port-related state, such as vnet_start_xmit.
> 
> Patch 3 leverages from the NAPIfied Rx path, 
> dropping superfluous usage of the irqsave/irqrestores on the vio.lock
> where possible.

Series applied, thanks.

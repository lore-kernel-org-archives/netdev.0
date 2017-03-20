From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] liquidio: use meaningful names for IRQs
Date: Mon, 20 Mar 2017 08:15:30 -0700
Message-ID: <20170320081530.0f4cdbee@xeon-e3>
References: <20170313195804.GA1796@felix2.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, ricardo.farrington@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36010 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753946AbdCTPYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 11:24:44 -0400
Received: by mail-pg0-f53.google.com with SMTP id g2so78658444pge.3
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 08:23:58 -0700 (PDT)
In-Reply-To: <20170313195804.GA1796@felix2.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Mar 2017 12:58:04 -0700
Felix Manlunas <felix.manlunas@cavium.com> wrote:

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> All IRQs owned by the PF and VF drivers share the same nondescript name
> "octeon"; this makes it difficult to setup interrupt affinity.
> 
> Change the IRQ names to reflect their specific purpose:
> 
>     LiquidIO<id>-<func>-<type>-<queue pair num>
> 
> Examples:
>     LiquidIO0-pf0-rxtx-3
>     LiquidIO1-vf1-rxtx-0
>     LiquidIO0-pf0-aux
> 
> We cannot use netdev->name for naming the IRQs because:
> 
>     1.  Early during init, the PF and VF drivers require interrupts to
>         send/receive control data from the NIC firmware; so the PF and VF
>         must request IRQs long before the netdev struct is registered.
> 
>     2.  The IRQ name can only be specified at the time it is requested.
>         It cannot be changed after that.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Irqbalance used to parse the interrupt names and expect the network device name.

From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH net-next] liquidio: use meaningful names for IRQs
Date: Mon, 3 Apr 2017 15:25:48 +0530
Message-ID: <CA+sq2CdG9fBR-Hw3rULMJON3aFQkCXtEpgkfKTzYhd5s=Lo1Tw@mail.gmail.com>
References: <20170313195804.GA1796@felix2.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <raghu.vatsavayi@cavium.com>,
        "Chickles, Derek" <derek.chickles@cavium.com>,
        satananda.burla@cavium.com, ricardo.farrington@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:33381 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbdDCJzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:55:50 -0400
Received: by mail-wr0-f172.google.com with SMTP id w43so161130187wrb.0
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 02:55:50 -0700 (PDT)
In-Reply-To: <20170313195804.GA1796@felix2.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 1:28 AM, Felix Manlunas
<felix.manlunas@cavium.com> wrote:
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

Probably too late, but just my 2 cents.

If there are multiple LiquidIO cards connected in a system, wouldn't the same
issue of how to setup IRQ affinities arise ?
How do you map netdev->name to IRQ name ?

>
> We cannot use netdev->name for naming the IRQs because:
>
>     1.  Early during init, the PF and VF drivers require interrupts to
>         send/receive control data from the NIC firmware; so the PF and VF
>         must request IRQs long before the netdev struct is registered.
>
>     2.  The IRQ name can only be specified at the time it is requested.
>         It cannot be changed after that.

You can try splitting IRQ registration and register IRQs for sending/receiving
control data with above naming but for queues, IRQs can be registered after
netdev struct is registered.

Thanks,
Sunil.

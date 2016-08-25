From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] documentation: Document issues with VMs and XPS
 and drivers enabling it on their own
Date: Thu, 25 Aug 2016 14:37:49 -0700
Message-ID: <CAKgT0UchpHwZ6CpE5jhRRVSOqd7TE5-ixcNyaXcYksWX25-tag@mail.gmail.com>
References: <20160825213304.2A02E2900836@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33399 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754447AbcHYVhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 17:37:51 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so7366392ith.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:37:50 -0700 (PDT)
In-Reply-To: <20160825213304.2A02E2900836@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 2:33 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> From: Rick Jones <rick.jones2@hpe.com>
>
> Since XPS was first introduced two things have happened.  Some drivers
> have started enabling XPS on their own initiative, and it has been
> found that when a VM is sending data through a host interface with XPS
> enabled, that traffic can end-up seriously out of order.
>
> Signed-off-by: Rick Jones <rick.jones2@hpe.com>
>
> ---
>
> diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
> index 59f4db2..50cc888 100644
> --- a/Documentation/networking/scaling.txt
> +++ b/Documentation/networking/scaling.txt
> @@ -400,15 +400,31 @@ transport layer is responsible for setting ooo_okay appropriately. TCP,
>  for instance, sets the flag when all data for a connection has been
>  acknowledged.
>
> +When the traffic source is a VM running on the host, there is no
> +socket structure known to the host.  In this case, unless the VM is
> +itself CPU-pinned, the traffic being sent from it can end-up queued to
> +multiple transmit queues and end-up being transmitted out of order.
> +
> +In some cases this can result in a considerable loss of performance.
> +
> +In such situations, XPS should not be enabled at runtime, or
> +explicitly disabled if the NIC driver(s) in question enable it on
> +their own.  Othersise, if possible, the VMs should be CPU pinned.
> +

I think you meant "Otherwise" instead of "Othersise".

>  ==== XPS Configuration
>
> -XPS is only available if the kconfig symbol CONFIG_XPS is enabled (on by
> -default for SMP). The functionality remains disabled until explicitly
> -configured. To enable XPS, the bitmap of CPUs that may use a transmit
> -queue is configured using the sysfs file entry:
> +XPS is available only if the kconfig symbol CONFIG_XPS is enabled
> +prior to building the kernel.  It is enabled by default for SMP kernel
> +configurations.  In many cases the functionality remains disabled at
> +runtime until explicitly configured by the system administrator. To
> +enable XPS, the bitmap of CPUs that may use a transmit queue is
> +configured using the sysfs file entry:
>
>  /sys/class/net/<dev>/queues/tx-<n>/xps_cpus
>
> +However, some NIC drivers will configure XPS at runtime for the
> +interfaces they drive, via a call to netif_set_xps_queue.
> +
>  == Suggested Configuration
>
>  For a network device with a single transmission queue, XPS configuration

So other than the one typo the rest of this looks good to me.

Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>

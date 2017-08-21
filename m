From: Bhumika Goyal <bhumirks@gmail.com>
Subject: Re: [PATCH 0/6] drivers: make device_attribute const
Date: Mon, 21 Aug 2017 18:25:15 +0530
Message-ID: <CAOH+1jFeD-V-hcnnmKN+9oEbYkf_FrCW74xrPTA3_WABmuH=AA@mail.gmail.com>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: Julia Lawall <julia.lawall@lip6.fr>, rjw@rjwysocki.net,
        Len Brown <lenb@kernel.org>, jbacik@fb.com, jikos@kernel.org,
        benjamin.tissoires@redhat.com, manish.chopra@cavium.com,
        rahul.verma@cavium.com, Dept-GELinuxNICDev@cavium.com,
        harish.patil@cavium.com, cascardo@holoscopio.com, don@syst.com.br,
        dvhart@infradead.org, Andy Shevchenko <andy@infradead.org>,
        sre@kernel.org, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
        nbd-general@lists.sourceforge.net, linux-input@vger.kernel.org,
        netdev@vger.kernel.org,
        Platform Driver <platform-driver-x86@vger.kernel.org>,
        linux-pm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36972 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752695AbdHUMzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 08:55:16 -0400
In-Reply-To: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 5:13 PM, Bhumika Goyal <bhumirks@gmail.com> wrote:
> Make these const. Done using Coccinelle.
>
> @match disable optional_qualifier@
> identifier s;
> @@
> static struct device_attribute s = {...};
>
> @ref@
> position p;
> identifier match.s;
> @@
> s@p
>
> @good1@
> identifier match.s;
> expression e1;
> position ref.p;
> @@
> device_remove_file(e1,&s@p,...)
>
> @good2@
> identifier match.s;
> expression e1;
> position ref.p;
> @@
> device_create_file(e1,&s@p,...)
>
>
> @bad depends on  !good1 && !good2@
> position ref.p;
> identifier match.s;
> @@
> s@p
>
> @depends on forall !bad disable optional_qualifier@
> identifier match.s;
> @@
> static
> + const
> struct device_attribute s;
>
> Bhumika Goyal (6):
>   ACPI: make device_attribute const
>   nbd: make device_attribute const
>   hid: make device_attribute const
>   qlogic:  make device_attribute const
>   platform/x86: make device_attribute const
>   power: supply: make device_attribute const
>

Hello all,

The patches are all independent, so please take what seems relevant.

Thanks,
Bhumika

>  drivers/acpi/battery.c                               | 2 +-
>  drivers/acpi/sbs.c                                   | 2 +-
>  drivers/block/nbd.c                                  | 2 +-
>  drivers/hid/hid-core.c                               | 2 +-
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 ++--
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c    | 6 +++---
>  drivers/platform/x86/classmate-laptop.c              | 6 +++---
>  drivers/platform/x86/intel-rst.c                     | 4 ++--
>  drivers/power/supply/olpc_battery.c                  | 2 +-
>  9 files changed, 15 insertions(+), 15 deletions(-)
>
> --
> 1.9.1
>

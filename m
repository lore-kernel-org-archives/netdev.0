From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines
 configurable at build
Date: Tue, 15 Jul 2014 08:48:01 -0700
Message-ID: <CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
	<1405419341-31510-3-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:52963 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbaGOPsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 11:48:02 -0400
Received: by mail-qc0-f178.google.com with SMTP id x3so3176653qcv.37
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 08:48:01 -0700 (PDT)
In-Reply-To: <1405419341-31510-3-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 3:15 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>  drivers/net/bonding/Kconfig   | 16 ++++++++++++++++
>  drivers/net/bonding/bonding.h |  6 +++---
>  2 files changed, 19 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/bonding/Kconfig b/drivers/net/bonding/Kconfig
> index 7b1a0fa..28fb3af 100644
> --- a/drivers/net/bonding/Kconfig
> +++ b/drivers/net/bonding/Kconfig
> @@ -15,3 +15,19 @@ menuconfig BONDING
>
>           To compile this driver as a module, choose M here: the module
>           will be called bonding.
> +
> +if BONDING
> +
> +config BOND_MAX_VLAN_ENCAP
> +       int "Maximum number of stacked vlans on top of bonding"
> +       default "2"
> +

I don't think we should allow changing these defaults so easily.
Not a single HW supports 3 vlan tags. There is no standard for it either.
Why you would ever change this?

> +config BOND_MAX_ARP_TARGETS
> +       int "Maximum number of ip targets arp monitor supports"
> +       default "16"
> +
> +config BOND_DEFAULT_MIIMON
> +       int "Default miimon monitoring frequency in milliseconds"
> +       default "100"

or this?
imo existing built-ins are fine and adding extra knobs just scary.
Users will have different numbers here and somebody would
need to make sure that all different defaults still work.
We should be minimizing the number of knobs instead.

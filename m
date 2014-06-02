From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] atm: fore200e.c: Cleaning up uninitialized variables
Date: Sun, 1 Jun 2014 17:10:39 -0700
Message-ID: <CAOesGMi4SGRP6_WMgv3xz_QrGScktYGQEK-muCrE=ohFBfeBeQ@mail.gmail.com>
References: <1401577712-4447-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	linux-atm-general@lists.sourceforge.net,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:40685 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbaFBAKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 20:10:40 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so1764237qab.14
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 17:10:40 -0700 (PDT)
In-Reply-To: <1401577712-4447-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 31, 2014 at 4:08 PM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> There is a risk that the variable will be used without being initialized.
>
> This was largely found by using a static code analysis program called cppcheck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/atm/fore200e.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
> index 204814e..d4725fc 100644
> --- a/drivers/atm/fore200e.c
> +++ b/drivers/atm/fore200e.c
> @@ -2780,7 +2780,7 @@ static struct pci_driver fore200e_pca_driver = {
>
>  static int __init fore200e_module_init(void)
>  {
> -       int err;
> +       int err = 0;
>
>         printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");


I can see how a tool that doesn't know about Kconfig dependencies
might think so, but if you look at Kconfig you'll see that for this
driver to be enabled for building either CONFIG_SBUS or CONFIG_PCI
must be set, and if either of them is then this variable will not be
used without first being set.


-Olof

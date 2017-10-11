From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: only enable PCI wakeups when WOL is active
Date: Wed, 11 Oct 2017 15:26:51 -0700 (PDT)
Message-ID: <20171011.152651.2054751831392289579.davem@davemloft.net>
References: <20171011045652.6301-1-drake@endlessm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org, romieu@fr.zoreil.com,
        linux@enlessm.com
To: drake@endlessm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdJKW0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 18:26:52 -0400
In-Reply-To: <20171011045652.6301-1-drake@endlessm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Drake <drake@endlessm.com>
Date: Wed, 11 Oct 2017 12:56:52 +0800

> rtl_init_one() currently enables PCI wakeups if the ethernet device
> is found to be WOL-capable. There is no need to do this when
> rtl8169_set_wol() will correctly enable or disable the same wakeup flag
> when WOL is activated/deactivated.
> 
> This works around an ACPI DSDT bug which prevents the Acer laptop models
> Aspire ES1-533, Aspire ES1-732, PackardBell ENTE69AP and Gateway NE533
> from entering S3 suspend - even when no ethernet cable is connected.
> 
> On these platforms, the DSDT says that GPE08 is a wakeup source for
> ethernet, but this GPE fires as soon as the system goes into suspend,
> waking the system up immediately. Having the wakeup normally disabled
> avoids this issue in the default case.
> 
> With this change, WOL will continue to be unusable on these platforms
> (it will instantly wake up if WOL is later enabled by the user) but we
> do not expect this to be a commonly used feature on these consumer
> laptops. We have separately determined that WOL works fine without any
> ACPI GPEs enabled during sleep, so a DSDT fix or override would be
> possible to make WOL work.
> 
> Signed-off-by: Daniel Drake <drake@endlessm.com>

Applied, thank you.

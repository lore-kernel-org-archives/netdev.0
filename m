From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] 8139too in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 16:48:08 +0300
Message-ID: <54957E18.8000803@cogentembedded.com>
References: <001601d01c57$be1e65a0$3a5b30e0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, shangh@realtek.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:43947 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbaLTNsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 08:48:11 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so2170319lam.30
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2014 05:48:09 -0800 (PST)
In-Reply-To: <001601d01c57$be1e65a0$3a5b30e0$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2014 4:20 PM, Jia-Ju Bai wrote:

> I have actually tested 8139too driver on the real hardware(Realtek RTL8139D
> PCI Ethernet Controller), and find some potential bugs:
> The target file is drivers/net/ethernet/realtek/8139too.c, which is used to
> build 8139too.ko.

> (1) In the normal process of 8139too, netif_napi_add is called in
> rtl8139_init_one, but netif_napi_del is not called in rtl8139_remove_one.
> However, many other ethernet card drivers call them in pairs, even in the
> error handling paths, such as r8169 and igb.

> (2) In the normal process of 8139too, pci_enable_device and
> pci_disable_device are called in pairs in rtl8139_init_board(in
> rtl8139_init_one) and rtl8139_remove_one. However, when pci_enable_device
> has been called and pci_request_regions is failed in rtl8139_init_board,
> "err_out" segment in rtl8139_init_board is executed immediately to exit, but
> pci_disable_device is not called because "disable_dev_on_err = 0".

    Again, please fix one issue per patch.

> Meanwhile, I also write the patch to fix the bugs. I have run the patch on
> the hardware, it can work normally and fix the above bugs.

    Too bad you didn't provide a sign-off...

WBR, Sergei

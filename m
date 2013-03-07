From: Richard Genoud <richard.genoud@gmail.com>
Subject: Re: hv_netvsc: WARNING in softirq.c
Date: Thu, 7 Mar 2013 11:12:19 +0100
Message-ID: <CACQ1gAi1NNwJ_QDp7ipjwdYCskENGN=N-j+TFD5aHX8DHnoBQA@mail.gmail.com>
References: <20130228083437.GA28143@lnx-rg> <78fd1c1df13b449887de6e0b3505a988@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <CACQ1gAgyYp+Dxmk-0C3zfKK+CkEwQX51NvWjzkV7=8GC3CD=Qg@mail.gmail.com> <4147bb5a7cf547c19c6a5a6b459a957d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:43648 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab3CGKMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 05:12:40 -0500
In-Reply-To: <4147bb5a7cf547c19c6a5a6b459a957d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/6 Haiyang Zhang <haiyangz@microsoft.com>:
> I have found a simple way to reproduce this kind of warning:
> 1) reboot the VM (because this warning can be displayed only once.)
> 2) login to the host and open the VM [Settings]
> 3) Temporarily change the Network adapter's option [Virtual Switch] to "Not connected".
> 4) run dmesg, you should see the warning.
>
> The reason for the warning is -- netif_tx_disable() is called when the NIC
> is disconnected. And it's called within irq context. netif_tx_disable()
> calls local_bh_enable() which displays warning if in irq.
>
> The fix is to remove the unnecessary netif_tx_disable() in the netvsc_linkstatus_callback().
> I attached a patch. Would you like to test it on your side as well?
>
> Thanks,
> - Haiyang
>
Thanks for your reply.
I'll be able to test your patch in 2 or 3 weeks I guess (I haven't got
any access to the hyperV machine, the admin-sys is on holiday, and
it's a production server... So I don't want to mess with it right now
:) )

Regards,
Richard.

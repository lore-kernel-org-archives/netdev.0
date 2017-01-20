From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware
 interrupts after enabling local irq flags
Date: Thu, 19 Jan 2017 20:41:27 -0600
Message-ID: <b2e783f6-fa09-e287-8119-266299cdae22@lwfinger.net>
References: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, netdev@vger.kernel.org, rgummal@xilinx.com,
        Bharat Kumar Gogada <bharatku@xilinx.com>
To: Bharat Kumar Gogada <bharat.kumar.gogada@xilinx.com>,
        chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:36460 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdATCtf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 21:49:35 -0500
In-Reply-To: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2017 04:14 AM, Bharat Kumar Gogada wrote:
> -Realtek 8192CE chipset maintains local irq flags after enabling/disabling
> hardware interrupts.
> -Hardware interrupts are enabled before enabling the local irq
> flags(these flags are being checked in interrupt handler),
> leading to race condition on some RP, where the irq line between
> bridge and GIC goes high at ASSERT_INTx and goes low only
> at DEASSERT_INTx. In this kind of RP by the time ASSERT_INTx is seen
> irq_enable flag is still set to false, resulting in continuous
> interrupts seen by CPU as DEASSERT_INTx cannot be sent since
> flag is still false and making CPU stall.
> -Changing the sequence of setting these irq flags.
>
> Signed-off-by: Bharat Kumar Gogada <bharatku@xilinx.com>
> ---

This patch should be enhanced with the smb_xx() calls as suggested by by Lino.

The subject should be changed. I would suggest something like "rtlwifi: 
rtl8192ce: Prevent race condition when enabling interrupts", as it explains the 
condition you are preventing.

The other PCI drivers also have the same problem. Do you want to prepare the 
patches, or should I do it?

Larry

From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware
 interrupts after enabling local irq flags
Date: Fri, 20 Jan 2017 10:30:05 -0600
Message-ID: <07fff87e-4dc2-f7b1-76f1-263be2410905@lwfinger.net>
References: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
 <b2e783f6-fa09-e287-8119-266299cdae22@lwfinger.net>
 <8520D5D51A55D047800579B094147198263CA86D@XAP-PVEXMBX02.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ravikiran Gummaluri <rgummal@xilinx.com>
To: Bharat Kumar Gogada <bharat.kumar.gogada@xilinx.com>,
        "chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8520D5D51A55D047800579B094147198263CA86D@XAP-PVEXMBX02.xlnx.xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/2017 08:14 AM, Bharat Kumar Gogada wrote:
>  > On 01/19/2017 04:14 AM, Bharat Kumar Gogada wrote:
>>> -Realtek 8192CE chipset maintains local irq flags after enabling/disabling
>>> hardware interrupts.
>>> -Hardware interrupts are enabled before enabling the local irq
>>> flags(these flags are being checked in interrupt handler),
>>> leading to race condition on some RP, where the irq line between
>>> bridge and GIC goes high at ASSERT_INTx and goes low only
>>> at DEASSERT_INTx. In this kind of RP by the time ASSERT_INTx is seen
>>> irq_enable flag is still set to false, resulting in continuous
>>> interrupts seen by CPU as DEASSERT_INTx cannot be sent since
>>> flag is still false and making CPU stall.
>>> -Changing the sequence of setting these irq flags.
>>>
>>> Signed-off-by: Bharat Kumar Gogada <bharatku@xilinx.com>
>>> ---
>>
>> This patch should be enhanced with the smb_xx() calls as suggested by by Lino.
>>
>> The subject should be changed. I would suggest something like "rtlwifi:
>> rtl8192ce: Prevent race condition when enabling interrupts", as it explains the
>> condition you are preventing.
>>
>> The other PCI drivers also have the same problem. Do you want to prepare the
>> patches, or should I do it?
>>
> Thanks Larry. Please send out the patches adding the above enhancements suggested by Lino.

I have prepared a patch fixing all the drivers. By the way, what CPU hardware 
showed this problem?

Larry

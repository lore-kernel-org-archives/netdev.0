From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: RTL8192EE PCIe Wireless Network Adapter crashed with linux-4.13
Date: Fri, 15 Sep 2017 10:19:57 -0500
Message-ID: <1eb67d2e-dfbc-a2d0-8949-d4336191c07b@lwfinger.net>
References: <2WhCEttl4IJtrTB2AkJYmhbsu-kiR_5fU0A_Z7eWW05rbVE5tB86A_ZS8ek_FQFdgaZw1bfx0wFbxOa0Ydjv1T6BzBkIHtaWTbSptcpB_kg=@protonmail.com>
 <e8e75755-f8b4-e122-ea4a-99a691405d38@lwfinger.net>
 <jB0WJNG17mSfKo9m7T26r-b2Gr7mDL4lJ-1cWxeCJ6UCsA4TsxXz4znCLhYY5EASPQciwp1rf_xtwvDR-xzwD-OTApTUFoaVmIvahleDcJk=@protonmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "pkshih@realtek.com" <pkshih@realtek.com>,
        "johannes.berg@intel.com" <johannes.berg@intel.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Zwindl <zwindl@protonmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <jB0WJNG17mSfKo9m7T26r-b2Gr7mDL4lJ-1cWxeCJ6UCsA4TsxXz4znCLhYY5EASPQciwp1rf_xtwvDR-xzwD-OTApTUFoaVmIvahleDcJk=@protonmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/2017 05:10 AM, Zwindl wrote:
> 
>> -------- Original Message --------
>> Subject: Re: RTL8192EE PCIe Wireless Network Adapter crashed with linux-4.13
>> Local Time: 14 September 2017 6:05 PM
>> UTC Time: 14 September 2017 18:05
>> From: Larry.Finger@lwfinger.net
>> To: Zwindl <zwindl@protonmail.com>, linux-wireless@vger.kernel.org 
>> <linux-wireless@vger.kernel.org>
>> chaoming_li@realsil.com.cn <chaoming_li@realsil.com.cn>, kvalo@codeaurora.org 
>> <kvalo@codeaurora.org>, pkshih@realtek.com <pkshih@realtek.com>, 
>> johannes.berg@intel.com <johannes.berg@intel.com>, gregkh@linuxfoundation.org 
>> <gregkh@linuxfoundation.org>, netdev@vger.kernel.org <netdev@vger.kernel.org>, 
>> linux-kernel@vger.kernel.org <linux-kernel@vger.kernel.org>
>>
>> On 09/14/2017 08:30 AM, Zwindl wrote:
>> > Dear developers:
>> > I"m using Arch Linux with testing enabled, the current kernel version and
>> > details are
>> > `Linux zwindl 4.13.2-1-ARCH #1 SMP PREEMPT Thu Sep 14 02:57:34 UTC 2017 x86_64
>> > GNU/Linux`.
>> > The wireless card can"t work properly from the kernel 4.13. Here"s the log(in
>> > attachment) when NetworkManager trying to connect my wifi which is named as
>> > "TP", my mac addr hided as xx:xx:xx:xx:xx.
>> > What should I provide to help to debug?
>> > ZWindL.
>>
>> The BUG-ON arises in __intel_map_single() due to dir (for direction of DMA)
>> equal to DMA_NONE (3). When rtl8192ee calls pci_map_single(), it uses
>> PCI_DMA_TODEVICE (1). I followed the calling sequence through the entire chain,
>> and none of the routines made any changes to "dir", other that changing the type
>> from int to enum dma_data_direction. That would not have changed a 1 to a 3.
>>
>> I built a 4.13.2 system. The problem does not happen here. At this point, the
>> system has been up for about two hours. I did discover a small memory leak
>> associated with firmware loading, but that should not have caused the problem.
>> Nonetheless, I will be sending a patch to fix that problem.
>>
>> I will continue testing, although I doubt that the problem will happen here.
>>
>> How long had your system been up when the problem occurred? Your dmesg fragment
>> did not show any times. What kernels have you tried besides 4.13.2?
>>
>> Larry
> Oh, sorry, the original log is from `journalctl`.
> Here's the `dmesg` prints(error.txt). I can't determine which part is related, 
> so I paste all of it. I've tried 4.12.X(no issue), 4.13.1(issue), 4.13.2(issue).
> ZWindL

The output of dmesg is a lot more instructive than that of journalctl. I now 
know exactly the location that triggered the WARNING. I still do not understand 
it. In fact, it is likely a regression in kernel 4.13 that does not affect my 
Toshiba laptop, nor a Lenovo machine I have, but does affect your Lenovo laptop.

Is it possible for you to install the mainline source from vger.kernel.org using 
git and bisect the issue? It will take quite a bit of time, but it is likely the 
only way to find the offending change. If you are willing to try this, I will 
send you reasonably complete instructions.

By the way, it is usually better to load the dmesg output into a pastebin site 
and post the link. Sending the entire file to a list makes a lot of people 
receive a lot of data for which they have no interest.

Larry

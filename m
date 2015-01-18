From: Arend van Spriel <arend@broadcom.com>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Sun, 18 Jan 2015 18:48:55 +0100
Message-ID: <54BBF207.2030708@broadcom.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>	<CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w@mail.gmail.com> <CA+55aFzEr-R1anNm91pnM=ujfhBstJikZBVtduphff1PtccHDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <egrumbach@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	"Linux Wireless List" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:38582 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbbARRs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 12:48:58 -0500
In-Reply-To: <CA+55aFzEr-R1anNm91pnM=ujfhBstJikZBVtduphff1PtccHDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/15 17:53, Linus Torvalds wrote:
> On Sun, Jan 18, 2015 at 11:24 PM, Emmanuel Grumbach<egrumbach@gmail.com>  wrote:
>>
>> we have different scan flows based on the firmware version you have,
>> so it would help if you could tell me what firmware you have.
>
> Sure. It's the larest one I could find
>
>     iwlwifi 0000:01:00.0: loaded firmware version 23.11.10.0 op_mode iwlmvm
>
> with the actual firmware file being 'iwlwifi-7260-10.ucode' from the
> current linux-firmware tree.
>
> Iin a different email Arend van Spriel<arend@broadcom.com>  wrote:
>>
>> The function iwl_trans_pcie_stop_device() put device in low-power and
>> resets the cpu on the device.  So iwl_op_mode_hw_rf_kill ends up in
>> iwl_mvm_set_hw_rfkill_state which schedules cfg80211_rfkill_sync_work
>> and returns true if firmware is running.  The patch below might work.
>
> Any suggestions for how to best try to trigger this for testing?
> Looking at my logs, it turns out that I actually got this three times,
> but they were all on the same boot, and I think the first case might
> just have triggered the later ones.
>
> The trigger was turning off wifi from the wifi settings app due to
> being in an airplane when they were closing the doors. I don't *think*
> there was actually any wifi around at the time, which may or may not
> have made the scanning take longer and made it easier to trigger.
>
> But I've done it before (although this machine has been upgraded to
> F21 reasonably recently, and I did update the ucode file before the
> trip). And I did it afterwards to test. And it happened that one time
> (and then apparently kept happening during suspend/resume/shutdown,
> but as mentioned, I blame that on some sticky problem from the first
> time, and those events in turn happened because I couldn't get
> wireless to work afterwards).
>
> IOW, I'm not at all sure I can recreate it, so your "analyzing the
> source code for how this could happen" may be the only good way..

Your issue occurs when firmware is instructed by user-space, ie. 
wpa_supplicant(?), to do "scheduled scan". This type of scanning is done 
entirely in the device. Typically, this type of scanning is done by 
wpa_supplicant after 3 normal scans in which no configured networks were 
found. The idea is that the host can be idle while the device does the 
scanning and wakes up the host when a configured network is found.

So as you indicated you were in location where none of your configured 
networks were available. Flipping the rfkill switch in that situation is 
the way to trigger the issue.

Regards,
Arend

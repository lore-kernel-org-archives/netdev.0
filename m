From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Mon, 19 Jan 2015 04:53:24 +1200
Message-ID: <CA+55aFzEr-R1anNm91pnM=ujfhBstJikZBVtduphff1PtccHDw@mail.gmail.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
	<CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 18, 2015 at 11:24 PM, Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> we have different scan flows based on the firmware version you have,
> so it would help if you could tell me what firmware you have.

Sure. It's the larest one I could find

   iwlwifi 0000:01:00.0: loaded firmware version 23.11.10.0 op_mode iwlmvm

with the actual firmware file being 'iwlwifi-7260-10.ucode' from the
current linux-firmware tree.

Iin a different email Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>
> The function iwl_trans_pcie_stop_device() put device in low-power and
> resets the cpu on the device.  So iwl_op_mode_hw_rf_kill ends up in
> iwl_mvm_set_hw_rfkill_state which schedules cfg80211_rfkill_sync_work
> and returns true if firmware is running.  The patch below might work.

Any suggestions for how to best try to trigger this for testing?
Looking at my logs, it turns out that I actually got this three times,
but they were all on the same boot, and I think the first case might
just have triggered the later ones.

The trigger was turning off wifi from the wifi settings app due to
being in an airplane when they were closing the doors. I don't *think*
there was actually any wifi around at the time, which may or may not
have made the scanning take longer and made it easier to trigger.

But I've done it before (although this machine has been upgraded to
F21 reasonably recently, and I did update the ucode file before the
trip). And I did it afterwards to test. And it happened that one time
(and then apparently kept happening during suspend/resume/shutdown,
but as mentioned, I blame that on some sticky problem from the first
time, and those events in turn happened because I couldn't get
wireless to work afterwards).

IOW, I'm not at all sure I can recreate it, so your "analyzing the
source code for how this could happen" may be the only good way..

               Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

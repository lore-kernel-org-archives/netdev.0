From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Sun, 18 Jan 2015 21:41:08 +0200
Message-ID: <CANUX_P0cRVtMcsstQV0H5GCq+iOEq_=dEdWMMmVLu_yuF_1KVA@mail.gmail.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
	<CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w@mail.gmail.com>
	<CA+55aFzEr-R1anNm91pnM=ujfhBstJikZBVtduphff1PtccHDw@mail.gmail.com>
	<54BBF207.2030708@broadcom.com>
	<CA+55aFws=-MY+rUsEny=DsBx9gct93BnfeGXSnOCLxEFtvDj8A@mail.gmail.com>
	<CANUX_P1pmB2PD00N2r2LgjNL4fG6RuTPxsO8G2weU+8EeENPTg@mail.gmail.com>
	<CANUX_P3kv5ofQJLGyEvRSgetHg=TJsaVennLJWq3ummgRJHWgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arend van Spriel <arend@broadcom.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:46071 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbARTlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 14:41:11 -0500
In-Reply-To: <CANUX_P3kv5ofQJLGyEvRSgetHg=TJsaVennLJWq3ummgRJHWgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emmanuel Grumbach
egrumbach@gmail.com


On Sun, Jan 18, 2015 at 9:13 PM, Emmanuel Grumbach <egrumbach@gmail.com> wrote:
> On Sun, Jan 18, 2015 at 8:52 PM, Emmanuel Grumbach <egrumbach@gmail.com> wrote:
>> On Sun, Jan 18, 2015 at 8:40 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>> On Mon, Jan 19, 2015 at 5:48 AM, Arend van Spriel <arend@broadcom.com> wrote:
>>>>
>>>> So as you indicated you were in location where none of your configured
>>>> networks were available. Flipping the rfkill switch in that situation is the
>>>> way to trigger the issue.
>>>
>>> So you certainly seem to be able to explain the behavior I saw under
>>> the circumstances they happened.
>>>
>>> I suspect the best thing to do is to just apply your patch. I may not
>>> be able to really test it much for the next few days anyway. Emmanuel?
>>>
>>
>> Sorry - I was a bit busy.
>> The patch seems wrong, we can't really call that function from the
>> rfkill interrupt - it will blow up.
>> The good news is that I could reproduce the bug based on what Arend
>> pointed. I totally missed the fact
>> that it was scheduled scan - thanks Arend for that.
>>
>> So the system I have here doesn't have HW rfkill so I had to implement
>> a hook that fakes it,
>> but I can't reproduce the problem.
>> I'll come up with a patch.
>
>
> Ok - Here is the patch:
>
> diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c
> b/drivers/net/wireless/iwlwifi/mvm/ops.c
> index 384eefd..bbd8054 100644
> --- a/drivers/net/wireless/iwlwifi/mvm/ops.c
> +++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
> @@ -867,6 +867,9 @@ static bool iwl_mvm_set_hw_rfkill_state(struct
> iwl_op_mode *op_mode, bool state)
>         if (calibrating)
>                 iwl_abort_notification_waits(&mvm->notif_wait);
>
> +       if (state)
> +               mvm->scan_status = IWL_MVM_SCAN_NONE;
> +
>         /*
>          * Stop the device if we run OPERATIONAL firmware or if we are in the
>          * middle of the calibrations.
>
>
> I will send that for internal review, because I am not all that much
> familiar with this and I want the guy who wrote that code to take a
> look before I send a pull request, but that should help.
>
Nah this is bad...

I have a correct patch - pull request on the way.

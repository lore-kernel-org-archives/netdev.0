From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 4.7 FIX] brcmfmac: fix lockup when removing P2P interface
 after event timeout
Date: Fri, 17 Jun 2016 07:33:20 +0200
Message-ID: <CACna6rym3y0sqAUptgnt-mUiBidFGzVAzw4XcYr95q6MD2r5yw@mail.gmail.com>
References: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
 <877fdpw4no.fsf@kamboji.qca.qualcomm.com> <CACna6rzXzj4DJNA6855Qy6QnxETnYEPmqtw3Bcx8WWCtYwYvuw@mail.gmail.com>
 <87lh24v1n6.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lh24v1n6.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 June 2016 at 07:13, Kalle Valo <kvalo@codeaurora.org> wrote:
> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> writes:
>
>> On 16 June 2016 at 17:10, Kalle Valo <kvalo@codeaurora.org> wrote:
>>> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> writes:
>>>
>>>> Removing P2P interface is handled by sending a proper request to t=
he
>>>> firmware. On success firmware triggers an event and driver's handl=
er
>>>> removes a matching interface.
>>>>
>>>> However on event timeout we remove interface directly from the cfg=
80211
>>>> callback. Current code doesn't handle this case correctly as it al=
ways
>>>> assumes rtnl to be unlocked.
>>>>
>>>> Fix it by adding an extra rtnl_locked parameter to functions and c=
alling
>>>> unregister_netdevice when needed.
>>>>
>>>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>>>
>>> Failed to apply, please rebase:
>>>
>>> Applying: brcmfmac: fix lockup when removing P2P interface after ev=
ent timeout
>>> Using index info to reconstruct a base tree...
>>> Falling back to patching base and 3-way merge...
>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.=
h
>>> CONFLICT (content): Merge conflict in drivers/net/wireless/broadcom=
/brcm80211/brcmfmac/core.h
>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.=
c
>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80=
211.c
>>> Failed to merge in the changes.
>>> Patch failed at 0001 brcmfmac: fix lockup when removing P2P interfa=
ce after event timeout
>>
>> What tree did you try it on?
>>
>> I just went into a dir where I have cloned:
>> git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers=
=2Egit
>>
>> My HEAD commit is:
>> 034fdd4 Merge ath-current from ath.git
>>
>> And I can apply this patch cleanly doing:
>> curl https://patchwork.kernel.org/patch/9138925/mbox/ | git am
>
> I was trying to apply this to wireless-drivers-next. I didn't get a
> confirmation from Arend and I didn't consider the fix important enoug=
h
> for 4.7. But of course I can reconsider if needed.

I think I agree it won't hurt to get it into -next. Noone earlier
reported this bug and it seems to be there for a long time. Also
applying it to -next will allow avoiding merge conflicts and immediate
development work on -next.

I'll resend this patch rebased on -next soon.

--=20
Rafa=C5=82

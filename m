From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 4.7 FIX] brcmfmac: fix lockup when removing P2P interface after event timeout
Date: Fri, 17 Jun 2016 08:13:17 +0300
Message-ID: <87lh24v1n6.fsf@kamboji.qca.qualcomm.com>
References: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
	<877fdpw4no.fsf@kamboji.qca.qualcomm.com>
	<CACna6rzXzj4DJNA6855Qy6QnxETnYEPmqtw3Bcx8WWCtYwYvuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky \(Zhenhui\) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rzXzj4DJNA6855Qy6QnxETnYEPmqtw3Bcx8WWCtYwYvuw@mail.gmail.com>
	(=?utf-8?Q?=22Rafa=C5=82_Mi=C5=82ecki=22's?= message of "Fri, 17 Jun 2016
 06:59:42 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> writes:

> On 16 June 2016 at 17:10, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> writes:
>>
>>> Removing P2P interface is handled by sending a proper request to th=
e
>>> firmware. On success firmware triggers an event and driver's handle=
r
>>> removes a matching interface.
>>>
>>> However on event timeout we remove interface directly from the cfg8=
0211
>>> callback. Current code doesn't handle this case correctly as it alw=
ays
>>> assumes rtnl to be unlocked.
>>>
>>> Fix it by adding an extra rtnl_locked parameter to functions and ca=
lling
>>> unregister_netdevice when needed.
>>>
>>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>>
>> Failed to apply, please rebase:
>>
>> Applying: brcmfmac: fix lockup when removing P2P interface after eve=
nt timeout
>> Using index info to reconstruct a base tree...
>> Falling back to patching base and 3-way merge...
>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
>> CONFLICT (content): Merge conflict in drivers/net/wireless/broadcom/=
brcm80211/brcmfmac/core.h
>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg802=
11.c
>> Failed to merge in the changes.
>> Patch failed at 0001 brcmfmac: fix lockup when removing P2P interfac=
e after event timeout
>
> What tree did you try it on?
>
> I just went into a dir where I have cloned:
> git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.=
git
>
> My HEAD commit is:
> 034fdd4 Merge ath-current from ath.git
>
> And I can apply this patch cleanly doing:
> curl https://patchwork.kernel.org/patch/9138925/mbox/ | git am

I was trying to apply this to wireless-drivers-next. I didn't get a
confirmation from Arend and I didn't consider the fix important enough
for 4.7. But of course I can reconsider if needed.

--=20
Kalle Valo

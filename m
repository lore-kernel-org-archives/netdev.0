From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] brcmfmac: rework function picking free BSS index
Date: Mon, 13 Jun 2016 22:25:05 +0200
Message-ID: <CACna6rwJUFzBbggtcmz_LYLRe-9TN1LeKtsGDuavLhAkWD90nQ@mail.gmail.com>
References: <1464219876-13776-1-git-send-email-zajec5@gmail.com>
 <5759C09F.7020704@broadcom.com> <575F09D7.6030505@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <575F09D7.6030505@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13 June 2016 at 21:30, Arend van Spriel <arend.vanspriel@broadcom.co=
m> wrote:
> On 09-06-16 21:16, Arend van Spriel wrote:
>> On 26-05-16 01:44, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> The old implementation was overcomplicated and slightly bugged in s=
ome
>>> corner cases.
>>>
>
> [...]
>
>>> New code is simpler, placed in file where it's really used, handles
>>> running out of free BSS-es and allows using 4 interfaces at the sam=
e
>>> time. It also looks for the first free BSS instead of one after the=
 last
>>> in use. It works well with current driver (which doesn't allow dele=
ting
>>> interfaces) and should be future proof (if we ever allow deleting).
>>>
>>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>>> ---
>>>  .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 17 ++++++++++=
++++-
>>>  .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 24 ----------=
------------
>>>  .../wireless/broadcom/brcm80211/brcmfmac/core.h    |  1 -
>>>  3 files changed, 16 insertions(+), 26 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80=
211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>>> index 3d09d23..d00eef8 100644
>>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>>> @@ -541,6 +541,21 @@ brcmf_cfg80211_update_proto_addr_mode(struct w=
ireless_dev *wdev)
>>>                                              ADDR_INDIRECT);
>>>  }
>>>
>>> +static int brcmf_get_first_free_bsscfgidx(struct brcmf_pub *drvr)
>>> +{
>>> +    int bsscfgidx;
>>> +
>>> +    for (bsscfgidx =3D 0; bsscfgidx < BRCMF_MAX_IFS; bsscfgidx++) =
{
>>> +            /* bsscfgidx 1 is reserved for legacy P2P */
>>
>> Hi Rafa=C5=82,
>>
>> A bit late as the patch is already applied, but this reserved index =
is
>> no longer needed as we removed all trickery that was build on the
>> assumption that the P2P_DEVICE interface was always in bsscfgidx 1.
>> Hence this could be removed.
>
> I tested STA on bsscfgidx=3D0, AP on bsscfgidx=3D1, and P2P_DEV on
> bsscfgidx=3D2. P2P discovery on P2P_DEV interface works as expected s=
o we
> can indeed drop the 'bsscfgidx 1 is reserved' statement. I want to
> verify on an older device before creating a patch.

Thanks for taking look at this.

--=20
Rafa=C5=82

From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: fixes the trivial print
Date: Tue, 13 Jun 2017 10:04:36 +0300
Message-ID: <87mv9c74hn.fsf@kamboji.qca.qualcomm.com>
References: <1497008411-15223-1-git-send-email-wxt@rock-chips.com>
        <87poe8pfjs.fsf@purkki.adurom.net>
        <b5621250-c9c8-b413-0dae-88b326c729bf@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: amitkarwar@gmail.com, huxm@marvell.com, nishants@marvell.com,
        gbhat@marvell.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        briannorris@chromium.org, jeffy.chen@rock-chips.com
To: Caesar Wang <wxt@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b5621250-c9c8-b413-0dae-88b326c729bf@rock-chips.com> (Caesar
        Wang's message of "Tue, 13 Jun 2017 14:54:15 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caesar Wang <wxt@rock-chips.com> writes:

> Kalle,
>
> =E5=9C=A8 2017=E5=B9=B406=E6=9C=8813=E6=97=A5 14:28, Kalle Valo =E5=86=99=
=E9=81=93:
>> Caesar Wang <wxt@rock-chips.com> writes:
>>
>>> We have always met the unused log be printed as following.
>>>
>>> ...
>>> [23193.523182] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp:
>>> cannot find cfp by band 2    & channel=3D13 freq=3D0
>>> [23378.633684] mwifiex_pcie 0000:01:00.0: mwifiex_get_cfp:
>>> cannot find cfp by band 2    & channel=3D13 freq=3D0
>>>
>>> Maybe that's related to wifi regdom, since wifi default area
>>> was US and didn't support 12~14 channels.
>>>
>>> As Frequencies:
>>> * 2412 MHz [1] (30.0 dBm)
>>> * 2417 MHz [2] (30.0 dBm)
>>> * 2422 MHz [3] (30.0 dBm)
>>> * 2427 MHz [4] (30.0 dBm)
>>> * 2432 MHz [5] (30.0 dBm)
>>> * 2437 MHz [6] (30.0 dBm)
>>> * 2442 MHz [7] (30.0 dBm)
>>> * 2447 MHz [8] (30.0 dBm)
>>> * 2452 MHz [9] (30.0 dBm)
>>> * 2457 MHz [10] (30.0 dBm)
>>> * 2462 MHz [11] (30.0 dBm)
>>> * 2467 MHz [12] (disabled)
>>> * 2472 MHz [13] (disabled)
>>> * 2484 MHz [14] (disabled)
>>>
>>> Signed-off-by: Caesar Wang <wxt@rock-chips.com>
>>> ---
>>>
>>>   drivers/net/wireless/marvell/mwifiex/cfp.c | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/wireless/marvell/mwifiex/cfp.c b/drivers/net/w=
ireless/marvell/mwifiex/cfp.c
>>> index 1ff2205..6e29943 100644
>>> --- a/drivers/net/wireless/marvell/mwifiex/cfp.c
>>> +++ b/drivers/net/wireless/marvell/mwifiex/cfp.c
>>> @@ -350,7 +350,7 @@ mwifiex_get_cfp(struct mwifiex_private *priv, u8 ba=
nd, u16 channel, u32 freq)
>>>   		}
>>>   	}
>>>   	if (i =3D=3D sband->n_channels) {
>>> -		mwifiex_dbg(priv->adapter, ERROR,
>>> +		mwifiex_dbg(priv->adapter, WARN,
>>>   			    "%s: cannot find cfp by band %d\t"
>>>   			    "& channel=3D%d freq=3D%d\n",
>>>   			    __func__, band, channel, freq);
>> I don't see how this fixes anything, care to explain? And the title is
>> quite vague.
>
> Sorry for the description maybe unclear.
> I'm assuming the print log is expected for marvel wifi driver. Do we
> should use 'WARN' to instead of the 'ERROR' here.

But does that make any functional difference, isn't the warning still
printed?

--=20
Kalle Valo

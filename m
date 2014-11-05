From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V2 1/4] can: m_can: update to support CAN FD features
Date: Wed, 05 Nov 2014 15:35:38 +0100
Message-ID: <545A35BA.8050607@hartkopp.net>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com> <5459F808.3020903@hartkopp.net> <20141105112639.GB4007@shlinux1.ap.freescale.net> <545A21AD.5040608@hartkopp.net> <545A23DA.7030303@pengutronix.de> <20141105134625.GG4007@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141105134625.GG4007@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05.11.2014 14:46, Dong Aisheng wrote:
> On Wed, Nov 05, 2014 at 02:19:22PM +0100, Marc Kleine-Budde wrote:
>> On 11/05/2014 02:10 PM, Oliver Hartkopp wrote:
>>> On 05.11.2014 12:26, Dong Aisheng wrote:
>>>> On Wed, Nov 05, 2014 at 11:12:24AM +0100, Oliver Hartkopp wrote:
>>>>> On 05.11.2014 08:58, Dong Aisheng wrote:
>>>
>>>
>>>>> Unfortunately No. Here it becomes complicated due to the fact tha=
t
>>>>> the revision 3.0.x does not support per-frame switching for FD/BR=
S
>>>>> ...
>>>>
>>>> I'm not sure i got your point.
>>>>   From m_can spec, it allows switch CAN mode by setting CMR bit.
>>>>
>>>> Bits 11:10 CMR[1:0]: CAN Mode Request
>>>> A change of the CAN operation mode is requested by writing to this=
 bit
>>>> field. After change to the
>>>> requested operation mode the bit field is reset to =E2=80=9C00=E2=80=
=9D and the status
>>>> flags FDBS and FDO are set
>>>> accordingly. In case the requested CAN operation mode is not enabl=
ed,
>>>> the value written to CMR is
>>>> retained until it is overwritten by the next mode change request. =
In
>>>> case CME =3D =E2=80=9C01=E2=80=9D/=E2=80=9D10=E2=80=9D/=E2=80=9D11=
=E2=80=9D a
>>>> change to CAN operation according to ISO 11898-1 is always possibl=
e.
>>>> Default is CAN operation
>>>> according to ISO11898-1.
>>>> 00 unchanged
>>>> 01 Request CAN FD operation
>>>> 10 Request CAN FD operation with bit rate switching
>>>> 11 Request CAN operation according ISO11898-1
>>>>
>>>> So what's the difference between this function and the per-frame
>>>> switching
>>>> you mentioned?
>>>>
>>>>>
>>>>> When (priv->can.ctrlmode & CAN_CTRLMODE_FD) is true this *only*
>>>>> tells us, that the controller is _capable_ to send either CAN or =
CAN
>>>>> FD frames.
>>>>>
>>>>> It does not configure the controller into one of these specific
>>>>> settings!
>>>>>
>>>>> Additionally: AFAIK when writing to the CCCR you have to make sur=
e
>>>>> that there's currently no ongoing transfer.
>>>>>
>>>>
>>>> I don't know about it before.
>>>> By searching m_can user manual v302 again, i still did not find th=
is
>>>> limitation. Can you point me if you know where it is?
>>>>
>>>> BTW, since we only use one Tx Buffer for transmission currently, s=
o we
>>>> should not meet th
> Regards
> Dong Aisheng
>
>> Marc
>>
>> --
>> Pengutronix e.K.                  | Marc Kleine-Budde           |
>> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
>> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
>> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
>>
>
>
at case that CAN mode is switched during transfer.
>>>> So the issue you concern may not happen.
>>>
>>> Yes. You are right. Having a FIFO with a size of 1 will help here :=
-)
>>
>> Errrr....sorry...no.
>>
>> Taking an easy route here but making it x times harder to extend the
>> driver to make use of the FIFO is not an option.
>>
>
> Hmm, this way is just following the original approach the current dri=
ver
> used. It's initial work and won't make things complicated.
>
> Extend the driver to use FIFO for TX is another story and based on
> my understanding it may be a bit complicated to do CAN FD mode switch=
 on this
> case due to hw limitation that the revision 3.0.x does not support pe=
r-frame
> switching for FD/BRS as Oliver pointed out.
> (e.g. how to switch FD MODE for each frame on Tx FIFO?)
> Probably that's why the 3.1.x version will add the FD/BRS bit control=
ler
> in Tx Buffer to fix this issue.
>
> Anyway, that's future work and we can discuss it when adding FIFO sup=
port
> for Tx function.
>

Yes. I have to second this opinion.

I also would like to have a TX FIFO. But due to the limitations of the =
3.0.x=20
M_CAN I would suggest to prefer a 'correct" CAN FD driver implementatio=
n in=20
favor of having a TX FIFO which is unusable for mixed CAN frame types.

Let's try the FIFO stuff with the next M_CAN revision.

It's a bit of a SJA1000 for CAN FD :-)

Regards,
Oliver

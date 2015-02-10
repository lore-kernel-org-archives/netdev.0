From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 09:51:31 +0100
Message-ID: <CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
	<CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@redhat.com>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33400 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449AbbBJIvc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 03:51:32 -0500
Received: by mail-ob0-f181.google.com with SMTP id vb8so30473073obc.12
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 00:51:31 -0800 (PST)
In-Reply-To: <CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 9:43 AM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
> On Tue, Feb 10, 2015 at 8:49 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>>>> On Mon, Feb 9, 2015 at 2:33 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wr=
ote:
>>>>> That is pretty old relative to this hardware. First commercial re=
lease?
>>>>> I don't really want to push you to do an upgrade, but it would su=
re be
>>>>> nice to have this test repeated on a recent firmware version.  No=
t that
>>>>> I can spot anything particularily promising in the release notes.
>>>>
>>>> I updated firmware now, but still see the same behavior.
>>>>
>>>>> I did find our previous discussions about these two RMNET1 and RM=
NET2
>>>>> functions, e.g:
>>>>> http://lists.freedesktop.org/archives/libqmi-devel/2014-July/0008=
75.html
>>>>> and it seems to indicate that both work as long as you configure =
them
>>>>> for 802.3 framing. But that could just be an information feedback
>>>>> loop...
>>>>
>>>> That is correct. In order for this device to accept network traffi=
c
>>>> (or driver to accept packets from device), I have to set the trans=
fer
>>>> mode to 802.3.
>>>
>>> So what are we going to do with this patch?
>>
>> I am hoping to get a second opinion from Aleksander.
>
> I have a MC7304 and a MC7354 and both work with interfaces #8 and #10=
,
> the only difference being that #10 ends up being raw-ip by default
> instead of 802.3. I previously had old firmware in both, from early
> last year IIRC, but last week I upgraded both to the latest firmware
> available.
>
> The only case in which I've seen such a modem (a MC7304) with 1 singl=
e
> valid QMI interface (actually being #8) is when the modem is put in
> "single-qmi" interface mode, which you can do forcing it to get the
> MC7710 PID, e.g. AT!UDPID=3D68A2. But otherwise, if the modem was
> exposed as 0x68c0, if#10 always worked for me...


BTW, regarding the patch... if interface #10 ends up being usable only
in some 73xx models, I would still leave it available anyway in the
kernel driver. Userspace can always figure out whether the interface
is usable or not (e.g. MM does some QMI probing on the interface
before flagging it as usable).

A similar issue we had with if#11 IIRC, which the sierra driver marked
it as being QMI but we never made it work once, so we ended up
removing it from qmi_wwan (see commit fc0d6e9cd0a). Now I wonder if we
should have done that only by testing it once with my hw.

--=20
Aleksander
https://aleksander.es

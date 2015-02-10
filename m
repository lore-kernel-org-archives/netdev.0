From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 10:10:40 +0100
Message-ID: <87r3tyb08f.fsf@nemi.mork.no>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
	<CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
	<CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@redhat.com>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37853 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753731AbbBJJKz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 04:10:55 -0500
In-Reply-To: <CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
	(Aleksander Morgado's message of "Tue, 10 Feb 2015 09:51:31 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aleksander Morgado <aleksander@aleksander.es> writes:
> On Tue, Feb 10, 2015 at 9:43 AM, Aleksander Morgado
> <aleksander@aleksander.es> wrote:
>> On Tue, Feb 10, 2015 at 8:49 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wro=
te:
>>
>>> I am hoping to get a second opinion from Aleksander.
>>
>> I have a MC7304 and a MC7354 and both work with interfaces #8 and #1=
0,
>> the only difference being that #10 ends up being raw-ip by default
>> instead of 802.3. I previously had old firmware in both, from early
>> last year IIRC, but last week I upgraded both to the latest firmware
>> available.
>>
>> The only case in which I've seen such a modem (a MC7304) with 1 sing=
le
>> valid QMI interface (actually being #8) is when the modem is put in
>> "single-qmi" interface mode, which you can do forcing it to get the
>> MC7710 PID, e.g. AT!UDPID=3D68A2. But otherwise, if the modem was
>> exposed as 0x68c0, if#10 always worked for me...
>
>
> BTW, regarding the patch... if interface #10 ends up being usable onl=
y
> in some 73xx models, I would still leave it available anyway in the
> kernel driver. Userspace can always figure out whether the interface
> is usable or not (e.g. MM does some QMI probing on the interface
> before flagging it as usable).

Yes, agreed.  Thanks for the testing.  Sorry Kristian, but if interface=
 #10
is usable on some modems with this device ID, then the driver should
support those modems.

So this is a NAK on the patch.

> A similar issue we had with if#11 IIRC, which the sierra driver marke=
d
> it as being QMI but we never made it work once, so we ended up
> removing it from qmi_wwan (see commit fc0d6e9cd0a). Now I wonder if w=
e
> should have done that only by testing it once with my hw.

Yes, it would be nice if you could revisit that just to be 103% sure.

I believe the driver will bind to any unbound QMI interfaces if you add
the device ID using the "new_id" sysfs file, so it should be testable
without rebuilding the kernel. At least on newer kernels, where the
dynamic USB ids override the built-in ones.

But contrary to the interface #10 situation, we have no indications tha=
t
#11 has ever worked for anyone.


Bj=C3=B8rn

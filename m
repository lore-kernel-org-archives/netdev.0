From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 08:52:49 +0000
Message-ID: <548020DD.3030705@audiocodes.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
 <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412012202480.1301@gmail.com>
 <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
 <547D37CA.7050506@audiocodes.com>
 <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com>
 <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com>
 <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
 <547D7243.80508@audiocodes.com>
 <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412021453340.7488@gmail.com>
 <1417532733483.89987@audiocodes.com>
 <alpine.LNX.2.03.1412021627360.8131@gmail.com>
 <547EA1D1.8010202@audiocodes.com>
 <alpine.LNX.2.03.1412030659001.1288@gmail.com>
 <547EA82F.5050500@audiocodes.com>
 <alpine.LNX.2.03.1412040730480.1320@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan@audiocodes.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1lrp0012.outbound.protection.outlook.com ([213.199.154.12]:15690
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752577AbaLDIxA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:53:00 -0500
In-Reply-To: <alpine.LNX.2.03.1412040730480.1320@gmail.com>
Content-Language: en-US
Content-ID: <FE7C62FDE51C524888C629D9EC276BB9@eurprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys,

After rearranging the padding, putting NCM0 right after NTH, and disabl=
e
ARP (FLAG_NOARP) and handling the offset alignment issue, it seems it
begins to work, though there's still problem with DHCP. It's able to
ping, though my Ubuntu network manage does not notice this network
interface. So no DNS.

I have to specify the network interface and IP in the ping command.

The DHCP packet's size becomes a large one after the TX function, which
is 16384, the maximum. And the dongle does not reply it in time. For
now, I just simple rearrange the code to meet Huawei's alignment
requirement. I think other devices may be different, regarding the
'offset' definition. We may need to handle it. And also need to double
check if the code has bugs.

Regards,
Kevin

On 12/04/2014 02:31 PM, Enrico Mioso wrote:
> Hello guys!
> I am writing this message to hear if there is any progress,
> Enrico
>
>
> On Wed, 3 Dec 2014, Kevin Zhu wrote:
>
>> Date: Wed, 3 Dec 2014 07:05:37
>> From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
>> To: Enrico Mioso <mrkiko.rs@gmail.com>
>> Cc: Bj=F8rn Mork <bjorn@mork.no>, Eli Britstein
>> <Eli.Britstein@audiocodes.com>,
>>     Alex Strizhevsky <alexxst@gmail.com>,
>>     Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
>>     "youtux@gmail.com" <youtux@gmail.com>,
>>     "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
>>     "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>> Subject: Re: Is this 32-bit NCM?
>>
>> OK. I will. Thank you for everything!
>>
>> Regards,
>> Kevin
>>
>> On 12/03/2014 02:00 PM, Enrico Mioso wrote:
>>> Yes - I think this would be ok. You might try this with the 16-bit
>>> river first,
>>> and then with the 32-bit one to see how things work.
>>> I hope for the best.
>>> Let us all know,
>>> Enrico
>>>
>>>
>>> On Wed, 3 Dec 2014, Kevin Zhu wrote:
>>>
>>> =3D=3DDate: Wed, 3 Dec 2014 06:38:27
>>> =3D=3DFrom: Kevin Zhu <Mingying.Zhu@audiocodes.com>
>>> =3D=3DTo: Enrico Mioso <mrkiko.rs@gmail.com>
>>> =3D=3DCc: Bj=F8rn Mork <bjorn@mork.no>, Eli Britstein
>>> <Eli.Britstein@audiocodes.com>,
>>> =3D=3D    Alex Strizhevsky <alexxst@gmail.com>,
>>> =3D=3D    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
>>> =3D=3D    "youtux@gmail.com" <youtux@gmail.com>,
>>> =3D=3D    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
>>> =3D=3D    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>>> =3D=3DSubject: Re: Is this 32-bit NCM?
>>> =3D=3D
>>> =3D=3DMy dongle also works with the huawei driver. I think only the=
 32bit
>>> =3D=3Dformat and NDP location matter. We may modify the TX function=
 to
>>> put NTH
>>> =3D=3Dand NDP at the beginning of a NTB and see if it will work wit=
h the
>>> =3D=3Ddriver cdc_ncm.
>>> =3D=3D
>>> =3D=3DRegards,
>>> =3D=3DKevin
>>> =3D=3D
>>> =3D=3DOn 12/02/2014 11:28 PM, Enrico Mioso wrote:
>>> =3D=3D> ... And what do you think about the source code of their nd=
is
>>> driver?
>>> =3D=3D> We at least know now the device work with it, so we have
>>> something to mimic :D
>>> =3D=3D> thank you for your work and patience Kevin.
>>> =3D=3D>
>>> =3D=3D> On Tue, 2 Dec 2014, Kevin Zhu wrote:
>>> =3D=3D>
>>> =3D=3D> =3D=3DDate: Tue, 2 Dec 2014 16:04:25
>>> =3D=3D> =3D=3DFrom: Kevin Zhu <Mingying.Zhu@audiocodes.com>
>>> =3D=3D> =3D=3DTo: Enrico Mioso <mrkiko.rs@gmail.com>, Bj=F8rn Mork
>>> <bjorn@mork.no>
>>> =3D=3D> =3D=3DCc: Eli Britstein <Eli.Britstein@audiocodes.com>,
>>> =3D=3D> =3D=3D    Alex Strizhevsky <alexxst@gmail.com>,
>>> =3D=3D> =3D=3D    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.c=
om>,
>>> =3D=3D> =3D=3D    "youtux@gmail.com" <youtux@gmail.com>,
>>> =3D=3D> =3D=3D    "linux-usb@vger.kernel.org" <linux-usb@vger.kerne=
l.org>,
>>> =3D=3D> =3D=3D    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>>> =3D=3D> =3D=3DSubject: Re: Is this 32-bit NCM?
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3DI do not understand why the wSequence matters. By the=
 way, I
>>> think I see some NDPs are right after NTH headers in the windows
>>> capture.
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3D________________________________________
>>> =3D=3D> =3D=3DFrom: Enrico Mioso <mrkiko.rs@gmail.com>
>>> =3D=3D> =3D=3DSent: Tuesday, December 2, 2014 21:53
>>> =3D=3D> =3D=3DTo: Bj=F8rn Mork
>>> =3D=3D> =3D=3DCc: Kevin Zhu; Eli Britstein; Alex Strizhevsky; Midge=
 Shaojun
>>> Tan; youtux@gmail.com; linux-usb@vger.kernel.org;
>>> netdev@vger.kernel.org
>>> =3D=3D> =3D=3DSubject: Re: Is this 32-bit NCM?
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3DThank you very much Bjorn.
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3DOn Tue, 2 Dec 2014, Bj=F8rn Mork wrote:
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3D=3D=3DDate: Tue, 2 Dec 2014 14:37:03
>>> =3D=3D> =3D=3D=3D=3DFrom: Bj=F8rn Mork <bjorn@mork.no>
>>> =3D=3D> =3D=3D=3D=3DTo: Enrico Mioso <mrkiko.rs@gmail.com>
>>> =3D=3D> =3D=3D=3D=3DCc: Kevin Zhu <Mingying.Zhu@audiocodes.com>,
>>> =3D=3D> =3D=3D=3D=3D    Eli Britstein <Eli.Britstein@audiocodes.com=
>,
>>> =3D=3D> =3D=3D=3D=3D    Alex Strizhevsky <alexxst@gmail.com>,
>>> =3D=3D> =3D=3D=3D=3D    Midge Shaojun Tan <ShaojunMidge.Tan@audioco=
des.com>,
>>> =3D=3D> =3D=3D=3D=3D    "youtux@gmail.com" <youtux@gmail.com>,
>>> =3D=3D> =3D=3D=3D=3D    "linux-usb@vger.kernel.org" <linux-usb@vger=
=2Ekernel.org>,
>>> =3D=3D> =3D=3D=3D=3D    "netdev@vger.kernel.org" <netdev@vger.kerne=
l.org>
>>> =3D=3D> =3D=3D=3D=3DSubject: Re: Is this 32-bit NCM?
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3D=3D=3DEnrico Mioso <mrkiko.rs@gmail.com> writes:
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3D=3D=3D> ... but out of curiosity: are NCM specs allow=
ing to change
>>> order of things in
>>> =3D=3D> =3D=3D=3D=3D> the package or not?
>>> =3D=3D> =3D=3D=3D=3D> This is not to start philosofical falames or =
something,
>>> but to understand
>>> =3D=3D> =3D=3D=3D=3D> better how things work. And, if they do: how =
much
>>> arbitrarily?
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3D=3D=3DOnly the NTB header has a fixed location. The r=
est can be
>>> anywhere and
>>> =3D=3D> =3D=3D=3D=3Din any order. Quoting from section 3 Data Trans=
port:
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3D=3D=3D  "Within any given NTB, the NTH always must be=
 first; but
>>> the other
>>> =3D=3D> =3D=3D=3D=3D   items may occur in arbitrary order."
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3D=3D=3DBj=F8rn
>>> =3D=3D> =3D=3D=3D=3D
>>> =3D=3D> =3D=3DThis email and any files transmitted with it are conf=
idential
>>> material. They are intended solely for the use of the designated
>>> individual or entity to whom they are addressed. If the reader of
>>> this message is not the intended recipient, you are hereby notified
>>> that any dissemination, use, distribution or copying of this
>>> communication is strictly prohibited and may be unlawful.
>>> =3D=3D> =3D=3D
>>> =3D=3D> =3D=3DIf you have received this email in error please immed=
iately
>>> notify the sender and delete or destroy any copy of this message
>>> =3D=3D> =3D=3D
>>> =3D=3DThis email and any files transmitted with it are confidential
>>> material. They are intended solely for the use of the designated
>>> individual or entity to whom they are addressed. If the reader of
>>> this message is not the intended recipient, you are hereby notified
>>> that any dissemination, use, distribution or copying of this
>>> communication is strictly prohibited and may be unlawful.
>>> =3D=3D
>>> =3D=3DIf you have received this email in error please immediately n=
otify
>>> the sender and delete or destroy any copy of this message
>>> =3D=3D
>> This email and any files transmitted with it are confidential
>> material. They are intended solely for the use of the designated
>> individual or entity to whom they are addressed. If the reader of
>> this message is not the intended recipient, you are hereby notified
>> that any dissemination, use, distribution or copying of this
>> communication is strictly prohibited and may be unlawful.
>>
>> If you have received this email in error please immediately notify
>> the sender and delete or destroy any copy of this message
>>
This email and any files transmitted with it are confidential material.=
 They are intended solely for the use of the designated individual or e=
ntity to whom they are addressed. If the reader of this message is not =
the intended recipient, you are hereby notified that any dissemination,=
 use, distribution or copying of this communication is strictly prohibi=
ted and may be unlawful.

If you have received this email in error please immediately notify the =
sender and delete or destroy any copy of this message

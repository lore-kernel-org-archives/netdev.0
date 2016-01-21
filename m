From: Joao Martins <joao.m.martins@oracle.com>
Subject: Re: xen-netfront crash when detaching network while some network
 activity
Date: Thu, 21 Jan 2016 12:30:48 +0000
Message-ID: <56A0CF78.1090901@oracle.com>
References: <20150522114932.GC8664@mail-itl> <55645140.1050209@citrix.com>
 <20150526220312.GA1358@mail-itl> <20151021185734.GD31646@mail-itl>
 <20151117024515.GN976@mail-itl> <20151201220042.GC22107@char.us.oracle.com>
 <20151201223258.GH1337@mail-itl> <20160120215914.GA6384@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Annie Li <annie.li@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	=?UTF-8?Q?Marek_Marczykowski-G=c3=b3recki?=
	<marmarek@invisiblethingslab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38716 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759214AbcAUMau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 07:30:50 -0500
In-Reply-To: <20160120215914.GA6384@char.us.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/20/2016 09:59 PM, Konrad Rzeszutek Wilk wrote:
> On Tue, Dec 01, 2015 at 11:32:58PM +0100, Marek Marczykowski-G=F3reck=
i wrote:
>> On Tue, Dec 01, 2015 at 05:00:42PM -0500, Konrad Rzeszutek Wilk wrot=
e:
>>> On Tue, Nov 17, 2015 at 03:45:15AM +0100, Marek Marczykowski-G=F3re=
cki wrote:
>>>> On Wed, Oct 21, 2015 at 08:57:34PM +0200, Marek Marczykowski-G=F3r=
ecki wrote:
>>>>> On Wed, May 27, 2015 at 12:03:12AM +0200, Marek Marczykowski-G=F3=
recki wrote:
>>>>>> On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
>>>>>>> On 22/05/15 12:49, Marek Marczykowski-G=F3recki wrote:
>>>>>>>> Hi all,
>>>>>>>>
>>>>>>>> I'm experiencing xen-netfront crash when doing xl network-deta=
ch while
>>>>>>>> some network activity is going on at the same time. It happens=
 only when
>>>>>>>> domU has more than one vcpu. Not sure if this matters, but the=
 backend
>>>>>>>> is in another domU (not dom0). I'm using Xen 4.2.2. It happens=
 on kernel
>>>>>>>> 3.9.4 and 4.1-rc1 as well.
>>>>>>>>
>>>>>>>> Steps to reproduce:
>>>>>>>> 1. Start the domU with some network interface
>>>>>>>> 2. Call there 'ping -f some-IP'
>>>>>>>> 3. Call 'xl network-detach NAME 0'
>>>
>>> Do you see this all the time or just on occassions?
>>
>> Using above procedure - all the time.
>>
>>> I tried to reproduce it and couldn't see it. Is your VM an PV or HV=
M?
>>
>> PV, started by libvirt. This may have something to do, the problem d=
idn't
>> existed on older Xen (4.1) and started by xl. I'm not sure about ker=
nel
>> version there, but I think I've tried there 3.18 too, which has this
>> problem.
>>
>> But I don't see anything special in domU config file (neither backen=
d
>> nor frontend) - it may be some libvirt default. If that's really the
>> cause. Can I (and how) get any useful information about that?
>=20
> libvirt naturally does some libxl calls, and they may be different.
>=20
> Any chance you could give me an idea of:
>  - What commands you use in libvirt?
>  - Do you use a bond or bridge?
>  - What version of libvirt you are using?
>=20
> Thanks!
> CC-ing Joao just in case he has seen this.
>>
Hm, So far I couldn't reproduce the issue with upstream Xen/linux/libvi=
rt, using
both libvirt or plain xl (both on a bridge setup) and also irrespective=
 of the
both load and direction of traffic (be it a ping flood, pktgen with min=
=2E
sized packets or iperf).

>>
>> --=20
>> Best Regards,
>> Marek Marczykowski-G=F3recki
>> Invisible Things Lab
>> A: Because it messes up the order in which people normally read text=
=2E
>> Q: Why is top-posting such a bad thing?
>=20
>=20

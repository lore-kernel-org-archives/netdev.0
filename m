From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 4 Nov 2009 12:45:13 +0900
Message-ID: <b30d1c3b0911031945l1e46aa53wee51579ef908c744@mail.gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>
	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:60300 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289AbZKDDpI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 22:45:08 -0500
Received: by vws30 with SMTP id 30so1813721vws.33
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 19:45:14 -0800 (PST)
In-Reply-To: <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 12:13 PM, Ryousei Takano <ryousei@gmail.com> wro=
te:
> Hi Patrick and Stephen,
>
> Thanks for your comments.
>
> I retried on the newer kernel and iproute2, and added the experimenta=
l result
> on my page. =A0Please see 'Experimental result 2':
> =A0 =A0http://code.google.com/p/pspacer/wiki/HTBon10GbE
>
> The accuracy improves compared with the previous experiment.
> The difference reduces from +810 Mbps to +430 Mbps.
> It is because the timer resolution improves from 1 usec to 1/64 usec.
> But it is not perfect.
>
Oops, not 1/64 usec but 1/16 usec.


> Best regards,
> Ryousei Takano
>
>
> On Tue, Nov 3, 2009 at 5:53 AM, Stephen Hemminger <shemminger@vyatta.=
com> wrote:
>> On Mon, 02 Nov 2009 16:43:42 +0100
>> Patrick McHardy <kaber@trash.net> wrote:
>>
>>> Ryousei Takano wrote:
>>> > Hi Stephen and all,
>>> >
>>> > I have observed a HTB accuracy problem on the Linux kernel 2.6.30=
 and
>>> > the Myri-10G 10 GbE NIC.
>>> > HTB can control the transmission rate at Gigabit speed, however i=
t can
>>> > not work well at 10 Gigabit speed.
>>> >
>>> > I asked Stephen this problem at Japan Linux Symposium. =A0He ment=
ioned a
>>> > HTB bug related to the timer granularity.
>>> > I want to know what is happen, and what should be do for fixing i=
t.
>>> >
>>> > Any comments and suggestions will be welcome.
>>> >
>>> > For more detail, please see the following page:
>>> > http://code.google.com/p/pspacer/wiki/HTBon10GbE
>>>
>>> This is not an easy problem to fix. Userspace, the kernel and the
>>> netlink API use 32 bit for timing related values, which is too smal=
l
>>> to use more than microsecond resolution. All of them need to be
>>> converted to use bigger types, additionally some kind of compatibil=
ity
>>> handling to deal with old iproute versions still using microsecond
>>> resolution is required.
>>
>> The existing API is a legacy mish-mash. The field is limited to 32 b=
its,
>> but it might be possible to use a finer scale.
>>
>> Maybe if kernel advertised finer resolution through /proc/net/psched
>> then table could be finer grained. This would maintain compatibility
>> between kernel and user space. You would need to have new kernel and
>> new iproute to get nanosecond resolution but older combinations woul=
d
>> still work.
>>
>> The downside is that by using nanosecond resolution the rates are up=
per
>> bounded at 4.2seconds / packet.
>>
>>
>

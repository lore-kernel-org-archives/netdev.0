From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Wed, 2 Apr 2008 13:40:55 +0200
Message-ID: <20080402114055.GA28569@atjola.homenet>
References: <47F1534A.7020402@nvidia.com> <20080401000502.GB7423@atjola.homenet> <47F180B8.6010801@nvidia.com> <20080402002459.GA22649@atjola.homenet> <47F1A044.6070200@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:60346 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753100AbYDBLlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 07:41:00 -0400
Content-Disposition: inline
In-Reply-To: <47F1A044.6070200@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.03.31 21:39:00 -0500, Ayaz Abdulla wrote:
> Bj=F6rn Steinbrink wrote:
>> On 2008.03.31 19:24:24 -0500, Ayaz Abdulla wrote:
>>> Bj=F6rn Steinbrink wrote:
>>>> On 2008.03.31 16:10:34 -0500, Ayaz Abdulla wrote:
>>>>> the device's mac address was in correct order and the flag   =20
>>>>> NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the=20
>>>>> flag would  get cleared. During next load, the mac address would=20
>>>>> get reversed  because the flag is missing.
>>>>
>>>> Hm, but nv_remove also writes back the reversed mac address. I don=
't see
>>>> how a plain remove/probe cycle would mess things up.
>>>
>>> For example, NVREG_TRANSMITPOLL_MAC_ADDR_REV is set. That would mea=
n =20
>>> that orig_mac will be stored with correct address. Then you call  =20
>>> nv_remove (via ifdown) which set orig_mac back into the register an=
d =20
>>> will clear the flag. On the next nv_probe (via ifup), you would=20
>>> perform  the logic to reverse the mac address. But it is still in=20
>>> correct order.
>>
>> OK, that's the case when we had two consecutive nv_probe calls, with=
out
>> a call to nv_remove in between, right? So yeah, kexec + rmmod + modp=
robe
>> breaks. AFAICT.
>
> Actually, I just realized the case I am looking at is different then =
=20
> ifdown/ifup. But it looks like you got it: kexec (nv_probe) + rmmod =20
> (nv_remove) + modprobe(nv_probe). I have seen it with =20
> insmod/rmmod/insmod since I don't know how kexec works.

I don't quite see how a plain insmod/rmmod/insmod causes that, but
anyway, I can see how the patch fixes a problem, so let's keep it at
that for now :-)

>>> My understanding is that nv_suspend will call nv_close and then  =20
>>> nv_resume will call nv_open. I don't think nv_probe/nv_remove is=20
>>> called  during the low power transitions.
>>
>> Hm, then I fail to see why my patch had any effect. I only touched
>> nv_probe and nv_remove, and it solved the mac reversal on suspend
>> problem... *confused*
>
> AFAICT nv_remove is not called during the power transitions.

After thinking through that a bit, I realized that the affected users
might have been using some userspace stuff to wrap the suspend/resume
cycle that did remove the forcedeth module prior to suspend. IIRC the
old hibernate shell script does that. That would explain why my patch
did the trick for them.

Anyway, the patch looks good to me.

Bj=F6rn

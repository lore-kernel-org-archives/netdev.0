From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [e1000e] BUG triggered in blink path
Date: Thu, 11 Nov 2010 15:59:31 -0800
Message-ID: <AANLkTi=hsJAVB9nUive0Xj9OGuyo0wo7Z9QMJH4DU_BA@mail.gmail.com>
References: <20101109083954.GB11829@mail.eitzenberger.org>
	<alpine.WNT.2.00.1011101030130.14720@jbrandeb-desk1.amr.corp.intel.com>
	<20101111101738.GA2972@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:34107 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab0KKX7c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 18:59:32 -0500
Received: by iwn10 with SMTP id 10so2768856iwn.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 15:59:32 -0800 (PST)
In-Reply-To: <20101111101738.GA2972@mail.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 02:17, Holger Eitzenberger
<holger@eitzenberger.org> wrote:
> Hi Jesse,
>
> I've attached the patch against net-next-2.6. =C2=A0Please check if i=
t's ok
> for you. =C2=A0I checked e1000, igb and ixgbe as well, they don't hav=
e that
> problem.
>
> =C2=A0/holger
>

Patch looks good, I have added the patch to my tree.

Cheers,
Jeff

>> > After taking a look I think this may be caused by initializing
>> > adapter->led_blink_task several times in e1000_phys_id(), while po=
ssibly
>> > led_blink_task is running:
>> >
>> > =C2=A0 =C2=A0 if ((hw->phy.type =3D=3D e1000_phy_ife) ||
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 (hw->mac.type =3D=3D e1000_pchlan) ||
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 (hw->mac.type =3D=3D e1000_82574)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_WORK(&adapter->led_=
blink_task, e1000e_led_blink_task);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!adapter->blink_time=
r.function) {
>> >
>> > I can't reproduce it after moving it inside the following if block=
,
>> > but I'm not quite sure if this catches all races in there. =C2=A0E=
specially
>> > the msleep_interruptible() may be too optimistic because it may
>> > actually not wait long enough. =C2=A0Someone with more knowledge o=
f the
>> > driver should take a look.
>>
>> thanks for your investigation and troubleshooting. =C2=A0I don't thi=
nk it is
>> correct at all to be calling INIT_WORK more than once. =C2=A0In fact=
 the
>> INIT_WORK should just be moved into probe, and then e1000_phys_id sh=
ould
>> just do schedule_work.
>>
>>
>

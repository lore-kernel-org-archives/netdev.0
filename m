From: Jesse Gross <jesse@nicira.com>
Subject: Re: bnx2 vlan issue
Date: Fri, 17 Jun 2011 09:47:27 -0700
Message-ID: <BANLkTinPQSB_Jc5xGL=pSLekun4LZjbGfA@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
 <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com>
 <AANLkTimAnHcoVDY_p8PqZLMJdMz2w7bMnSbOwzn4aR4i@mail.gmail.com>
 <AANLkTimJsBYefz3+3HgBgrHUR33g+TWuBp15E=VODohb@mail.gmail.com>
 <AANLkTik1JJO7mqxPzqfshMfH2JFUXn+yxbTqVdr4QDf6@mail.gmail.com>
 <AANLkTi=7ETnRWOLRVAWhv=3BHZdzUnLvAqzxXOz399Xx@mail.gmail.com>
 <AANLkTi=D9Qw+Tw7wHb2T7UG_o9zkZcr2meHE3fwcMwvF@mail.gmail.com>
 <AANLkTimnKRDY8QLiJMMLqNzCA_-6UJmUDHKf-i1Yt3V5@mail.gmail.com>
 <AANLkTi=zfhwHTB7kitgwk3AzSa0aFFyxgM_ZY-3wObR5@mail.gmail.com>
 <AANLkTi=gsP3ZZyEwO+CcM3uB6G5-QswYEfqdtiy8oOyv@mail.gmail.com>
 <AANLkTi=CaWMSmRsN8SXfn999=4RNnFESTLjyBytYVzR2@mail.gmail.com> <loom.20110617T075702-107@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dominique Martinet <rnfhrznznaq.tf@noclue.notk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48576 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1FQQrs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 12:47:48 -0400
Received: by vxi39 with SMTP id 39so2115402vxi.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 09:47:47 -0700 (PDT)
In-Reply-To: <loom.20110617T075702-107@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2011 at 11:10 PM, Dominique Martinet
<rnfhrznznaq.tf@noclue.notk.org> wrote:
> Hi,
>
> Jesse Gross <jesse <at> nicira.com> writes:
>> On Thu, Mar 24, 2011 at 5:26 PM, Seblu <seblu <at> seblu.net> wrote:
>> > Maybe i was not enough clear. It seems to me that new behaviour, w=
ith
>> > vlan on top of bridge rather than above interface in bridge is not
>> > functional.
>> > In other words, i cannot use vlan and bridge together in 2.6.38 (w=
ith
>> > e1000e).
>>
>> Sorry, I misunderstood what you were saying before. =C2=A0Can you tr=
y and
>> see where the packets are getting lost or improperly handled by
>> running tcpdump on the various interfaces? =C2=A0For example, check =
that
>> packets are coming in with tags on the physical interfaces, have tag=
s
>> on the bridge interface, no tag on the vlan interface, etc.
>
> I think I ran into the same problem, and my workaround for this was t=
o add
> a vlan do the bridge and then add the vlan'ed bridge to another bridg=
e, i.e.
> (since I can't draw, commands will be better :P)
>
> brctl addbr br0
> brctl addif br0 eth0
> ip link add link br0 name br0.42 type vlan id 42
> ip link set br0.42 up
>
> brctl addbr br_42
> brctl addif br_42 br0.42
>
> and then I could put VMs in br_42 which got network "as expected"
> before, I used to have br_42 with eth0.42 in it, so it is just one mo=
re
> step..
> What bothers me is that I also want to put VMs in br0, and it does wo=
rk,
> but this bridge also sees all the tagged data - isn't there a way to =
just
> "pick" the untagged network?

You are bridging the VMs to the physical network, so it is expected
that they will see all traffic.  That said, you could use ebtables to
only take vlan 0, similar to if you only wanted them to see packets to
their MAC address and not flooding.

> My other question is that I'm not certain if that's the expected way =
to
> use the new behaviour, if not I wouldn't mind light shining from abov=
e :)

Yes, that's the intended behavior and correct usage.

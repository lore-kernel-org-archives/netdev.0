From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Tue, 19 Jul 2011 10:27:32 +0200
Message-ID: <CAHXqBFKMFxDYo6yz_59PHEm4kn37iy3jk3YVpcyE6KY-nzCRbQ@mail.gmail.com>
References: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFKZf3keVdC3t0xDu8SEEWR3Utoo-zBiqMVOWiSxzm3ieQ@mail.gmail.com>
 <20110717073022.GA2089@minipsycho.orion> <CAHXqBFL1s30DxxHk-1wEy1q48LvgbO+w4zXkOm0sAU61XONoVw@mail.gmail.com>
 <20110717194421.GA2153@minipsycho> <CAHXqBFJ94hgCsHF-o8FNQPqpVexy4Z3Z+wY+G4MPDLmuYCx+Jg@mail.gmail.com>
 <20110718071300.GA2244@minipsycho> <CAHXqBFKgZUuLFoe+U+2nT3NVBCaPfY13BsrK=Hxqsw7oiOZe3A@mail.gmail.com>
 <20110719081332.GA2219@minipsycho> <CAHXqBFKZ2Y+SgFLFaBD6rpHoVX30PMp1ECwxhie3AAUqjMZ6UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56406 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab1GSI1w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 04:27:52 -0400
Received: by qwk3 with SMTP id 3so1874758qwk.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 01:27:52 -0700 (PDT)
In-Reply-To: <CAHXqBFKZ2Y+SgFLFaBD6rpHoVX30PMp1ECwxhie3AAUqjMZ6UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 19 lipca 2011 10:24 u=BFytkownik Micha=B3 Miros=B3aw
<mirqus@gmail.com> napisa=B3:
> W dniu 19 lipca 2011 10:13 u=BFytkownik Jiri Pirko <jpirko@redhat.com=
> napisa=B3:
>> Tue, Jul 19, 2011 at 09:24:29AM CEST, mirqus@gmail.com wrote:
>>>W dniu 18 lipca 2011 09:13 u=BFytkownik Jiri Pirko <jpirko@redhat.co=
m> napisa=B3:
>>>> =A0static u32 atl1c_fix_features(struct net_device *netdev, u32 fe=
atures)
>>>> =A0{
>>>> + =A0 =A0 =A0 u32 changed =3D netdev->features ^ features;
>>>> +
>>>> + =A0 =A0 =A0 /*
>>>> + =A0 =A0 =A0 =A0* Since there is no support for separate rx/tx vl=
an accel
>>>> + =A0 =A0 =A0 =A0* enable/disable make sure these are always set i=
n pair.
>>>> + =A0 =A0 =A0 =A0*/
>>>> + =A0 =A0 =A0 if ((changed & NETIF_F_HW_VLAN_TX && features & NETI=
=46_F_HW_VLAN_TX) ||
>>>> + =A0 =A0 =A0 =A0 =A0 (changed & NETIF_F_HW_VLAN_RX && features & =
NETIF_F_HW_VLAN_RX))
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_HW_VLAN_TX | N=
ETIF_F_HW_VLAN_RX;
>>>> + =A0 =A0 =A0 else
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features &=3D ~(NETIF_F_HW_VLAN_TX |=
 NETIF_F_HW_VLAN_RX);
>>>> +
>>>
>>>You ignored my hint about combined TX/RX offload. Is that on purpose=
?
>> Sorry but I'm probably missing what you mean.
>
> You could replace above code with:
>
> if (!(features & NETIF_F_HW_VLAN_RX))
> =A0features &=3D ~NETIF_F_HW_VLAN_TX;

Or you could invert the test and effect:

  if (features & NETIF_F_HW_VLAN_TX)
    features |=3D NETIF_F_HW_VLAN_RX;

Best Regards,
Micha=B3 Miros=B3aw

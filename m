From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy choice
Date: Wed, 15 Mar 2017 12:46:23 +0200
Message-ID: <B403ACFE-A028-454D-94C1-F7023457C87C@cumulusnetworks.com>
References: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com> <20170314085502.47d48a4e@xeon-e3> <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com> <20170314.114837.619141079617104809.davem@davemloft.net> <20170314132506.6233b1e7@xeon-e3> <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com> <20170314144204.20d5c3a5@xeon-e3> <CAJieiUgQpOidyE-OH73QQpMcQnzEgd+9bGPOKA-yAaFtb3fcwQ@mail.gmail.com> <20170314162715.141f1d4b@xeon-e3> <0c0473f7-beab-ea87-6dde-77aa345258ff@cumulusnetworks.com> <5b5cf0ac-d152-3c8e-d54b-1059f561efee@6wind.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35876 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753300AbdCOKqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 06:46:49 -0400
Received: by mail-wm0-f42.google.com with SMTP id n11so84228561wma.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 03:46:47 -0700 (PDT)
In-Reply-To: <5b5cf0ac-d152-3c8e-d54b-1059f561efee@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 15, 2017, at 11:17 AM, Nicolas Dichtel =
<nicolas.dichtel@6wind.com> wrote:
>=20
> Le 15/03/2017 =E0 00:45, David Ahern a =E9crit :
>> On 3/14/17 5:27 PM, Stephen Hemminger wrote:
>>> On Tue, 14 Mar 2017 15:38:40 -0700
>>> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>>>=20
>>>>>>>>> That's what my initial version did, but this was discussed =
during NetConf in Seville
>>>>>>>>> and it was decided that it's best to make a global sysctl, =
thus the change. =20
>>>>>>>>=20
>>>>>>>> Correct, we discussed this, and we all agreed to only have a =
sysctl for now. =20
>>>>>>>=20
>>>>>>> Why? If you are going to have private discussions please post =
the rationale
>>>>>>> in public. =20
>>>>>>=20
>>>>>> Stephen, is there any reason to have a per ecmp route multipath =
algo
>>>>>> selection ?.
>>>>>> All platforms have a global multipath selection algo. I also =
don't see
>>>>>> routing daemons ready or willing to specify a per ecmp route =
multipath
>>>>>> selection algo attribute. =20
>>>>>=20
>>>>> There is no compelling reason to make the attribute per route. But =
the
>>>>> issue is more that configuration through sysctl's is problematic. =
It doesn't
>>>>> fit into the standard API paradigm. Sysctl's are like routing =
patches not
>>>>> part of the real CLI. Trying to trap sysctl's for things like =
switchedev
>>>>> offload is particularly problematic. I can see the case for either =
way,
>>>>> and don't have a fixed opinion. =20
>>>>=20
>>>> ok. understand the switchdev offload part. It was that way in the =
past...but
>>>> today you can listen to sysctl updates on the netconf netlink =
channel.
>>>> it works pretty well.
>>>=20
>>> Is there another patch to add the NETCONFA_ECMP support?
>>>=20
>>=20
>> does userspace care?
> Yes, I think it is needed so that userspace can correctly monitor this =
behavior.
> It also enables to check this parameter through netlink.
>=20
>=20
> Regards,
> Nicolas

This doesn=92t fit the NETCONFA model well, there is no =93all=94, =
=93default=94 or per iface option to be set, also
the other multipath sysctl which affects behaviour doesn=92t have a =
notification.

Thanks,
 Nik

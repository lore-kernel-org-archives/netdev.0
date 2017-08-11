From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: Driver profiles RFC
Date: Fri, 11 Aug 2017 07:34:41 -0700
Message-ID: <CAJieiUgyJvWfqmX7--n=homKAwTas6gNLo482Ogxtv7VQC42vA@mail.gmail.com>
References: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
 <CAJieiUjvVaurfLGw4HCwfu-wwNpHkBH6Vq7APNj+vzu4CuNLdA@mail.gmail.com> <8c2cd3d2-70a8-b583-28af-6c0b1b6f82c0@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, ivecera@redhat.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
        mlxsw <mlxsw@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:33191 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbdHKOen (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 10:34:43 -0400
Received: by mail-vk0-f48.google.com with SMTP id j189so13938750vka.0
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 07:34:42 -0700 (PDT)
In-Reply-To: <8c2cd3d2-70a8-b583-28af-6c0b1b6f82c0@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 4:43 AM, Arkadi Sharshevsky <arkadis@mellanox.com> w=
rote:
>
>
> On 08/08/2017 07:08 PM, Roopa Prabhu wrote:
>> On Tue, Aug 8, 2017 at 6:15 AM, Arkadi Sharshevsky <arkadis@mellanox.com=
> wrote:
>>>

[snip]

>>> User Configuration
>>> ------------------
>>> Such an UAPI is very low level, and thus an average user may not know h=
ow to
>>> adjust this sizes according to his needs. The vendor can provide severa=
l
>>> tested configuration files that the user can choose from. Each config f=
ile
>>> will be measured in terms of: MAC addresses, L3 Neighbors (IPv4, IPv6),
>>> LPM entries (IPv4,IPv6) in order to provide approximate results. By thi=
s an
>>> average user will choose one of the provided ones. Furthermore, a more
>>> advanced user could play with the numbers for his personal benefit.
>>>
>>> Reference
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> [1] https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%=
2Fnetdevconf.org%2F2.1%2Fpapers%2Fdpipe_netdev_2_1.odt&data=3D02%7C01%7Cark=
adis%40mellanox.com%7Cc64b0d54e3e94d07b64c08d4de77bf8b%7Ca652971c7d2e4d9ba6=
a4d149256f461b%7C0%7C0%7C636378053281241266&sdata=3D9u%2BFwGF%2FjkmNogPF7Cm=
%2FfwJsaPVkr%2BC3%2F8x1IVbszRg%3D&reserved=3D0
>>>
>>
>> Thanks for sending this out. There is very much a need for this.
>> and agree, user-space app config can translate to what values they want =
and
>>  kernel api can be a low level api.
>>
>> But how about we align these resource limits with the kernel resource li=
mits ?
>> For example we usually map l3 hw neighbor limits to kernel software gc_t=
hresh
>> values (which are configurable via sysctl). This is one way to give
>> user immediate
>> feedback on resource full errors. It would be nice if we can introduce
>> limits for routes and
>> mac addresses. Defaults could be what they are today but user
>> configurable ...like I said,
>> neighbor subsystem already allows this.
>>
>
> Hi Roopa, thanks for the feedback.
>
> Regarding aligning the hardware tables sizes with the kernel software
> limits. The hardware resources (internal memory) are much more limited
> than the software one. Please consider the following scenario:
>
> 1. User adds limit to neighbor table (as you suggested), which uses the
>    hash memory portion.
> 2. User adds many routes, the routes uses the hash memory resource as wel=
l,
>    potentially.
> 3. The kernel adds some neighbors dynamically, the neighbor offloading
>    fails due to lack of this shared resource, the user get confused becau=
se
>    its lower then what he configured in 1).
>
> Thus providing max size on specific table is not well defined due to
> limited
> shared resource. Thus, the feedback the user gets can be not very accurat=
e.
> Furthermore, guessing the resource partitioning based only on the subset =
of
> tables which use it makes me little bit uncomfortable.

yep, understood. I am aware of  some of these problems as well.

>
> The proposed API aims at solving this issue by providing abstraction for
> this hw behavior, and provide the connection with the hardware table, thu=
s
> providing more accurate and well defined description of the system.
>
> I totally agree that this API should be enhanced in order provide the
> occupancy of the this 'resource'. For example, the user first observe the
> tables and sees the resource<->table mapping, then see the resource
> occupancy:
>
> #devlink dpipe resource occupancy pci/0000:03:00.0 Mem
>
> By this the user can understand the offloading limitation, and maybe figu=
re
> out that he should change the partitioning.
>

yes, sounds good.

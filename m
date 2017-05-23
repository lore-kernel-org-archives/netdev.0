From: =?UTF-8?B?S2/FgsWCxIV0YWosIFJlbWlnaXVzeg==?=
        <remigiusz.kollataj@mobica.com>
Subject: Re: [PATCH iproute2] ip: add handling for new CAN netlink interface
Date: Tue, 23 May 2017 10:47:15 +0200
Message-ID: <CAKT-o-eJi0Tt=4T+_SHb=sTMdR12dO3Frj+eN5sAkCy0MYXzKw@mail.gmail.com>
References: <20170519125449.7214-1-remigiusz.kollataj@mobica.com> <20170522133705.57e13882@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:35634 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966915AbdEWIrg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 04:47:36 -0400
Received: by mail-vk0-f43.google.com with SMTP id h16so54110654vkd.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 01:47:36 -0700 (PDT)
In-Reply-To: <20170522133705.57e13882@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On 22 May 2017 at 22:37, Stephen Hemminger <stephen@networkplumber.org> wro=
te:
> On Fri, 19 May 2017 14:54:49 +0200
> Remigiusz Ko=C5=82=C5=82=C4=85taj         <remigiusz.kollataj@mobica.com>=
 wrote:
>
>> This patch adds handling for new CAN netlink interface introduced in
>> 4.11 kernel:
>> - IFLA_CAN_TERMINATION,
>> - IFLA_CAN_TERMINATION_CONST,
>> - IFLA_CAN_BITRATE_CONST,
>> - IFLA_CAN_DATA_BITRATE_CONST
>>
>> Output example:
>> $ip -d link show can0
>> 6: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT group de=
fault qlen 10
>>     link/can  promiscuity 0
>>     can state STOPPED (berr-counter tx 0 rx 0) restart-ms 0
>>           bitrate 80000
>>              [   20000,    33333,    50000,    80000,    83333,   100000=
,
>>                 125000,   150000,   175000,   200000,   225000,   250000=
,
>>                 275000,   300000,   500000,   625000,   800000,  1000000=
 ]
>>           termination 0 [ 0, 120 ]
>>           clock 0numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_=
segs 65535
>>
>> Signed-off-by: Remigiusz Ko=C5=82=C5=82=C4=85taj <remigiusz.kollataj@mob=
ica.com>
>
> What is output without the -d flag?

Output _before_ changes:

$ ip link show can0
7: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc fq_codel state UNKNOWN
mode DEFAULT group default qlen 10
    link/can

7: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc fq_codel state UNKNOWN
mode DEFAULT group default qlen 10
    link/can  promiscuity 0
    can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
          bitrate 1000000 sample-point 0.000
          tq 0 prop-seg 0 phase-seg1 0 phase-seg2 0 sjw 0
          clock 0numtxqueues 1 numrxqueues 1 gso_max_size 65536
gso_max_segs 65535

Output _after_ changes:

$ ./ip link show can0
7: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc fq_codel state UNKNOWN
mode DEFAULT group default qlen 10
    link/can

$ ./ip -d link show can0
7: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc fq_codel state UNKNOWN
mode DEFAULT group default qlen 10
    link/can  promiscuity 0
    can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
          bitrate 1000000
             [   20000,    33333,    50000,    80000,    83333,   100000,
                125000,   150000,   175000,   200000,   225000,   250000,
                275000,   300000,   500000,   625000,   800000,  1000000 ]
          termination 0 [ 0, 120 ]
          clock 0numtxqueues 1 numrxqueues 1 gso_max_size 65536
gso_max_segs 65535

> In general iproute2 show commands are designed to be invertable.
> I.e the show command looks like the same command to set.
>
> Printing the bitrates and the format of the state output looks quite diff=
erent
> than the set command. Is it limited to detail (-d)?

The change is limited to -d indeed.

4.11 kernel introduced new mechanism for devices that have predefined
bitrates. Before the change there was no possibility to pass to user
space supported bitrate values (other than printk).

I was also wondering about changing the output to:

$ ./ip -d link show can0
7: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc fq_codel state UNKNOWN
mode DEFAULT group default qlen 10
    link/can  promiscuity 0
    can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
          bitrate 1000000
          bitrate_const  20000,    33333,    50000,    80000,
83333,   100000,
                125000,   150000,   175000,   200000,   225000,   250000,
                275000,   300000,   500000,   625000,   800000,  1000000
          termination 0
          termination_const 0, 120
          clock 0numtxqueues 1 numrxqueues 1 gso_max_size 65536
gso_max_segs 65535

Is it better from your point of view?


Regards,
Remik

--=20
____________________
Remigiusz Ko=C5=82=C5=82=C4=85taj
Mobica Ltd
Technology Consultant
Skype: remigiusz.kollataj
www.mobica.com

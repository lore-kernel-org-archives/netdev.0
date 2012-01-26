From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v1, kernel 3.2.1] RTNETLINK adjusting values of min_ifinfo_dump_size
Date: Thu, 26 Jan 2012 12:01:44 +0100
Message-ID: <CAGsizzLxWbCqKxMTc-_-7MDmWg_VgP63ZBmi7P2z_Y7YMtrehg@mail.gmail.com>
References: <30372884.681327480899559.JavaMail.root@5-MeO-DMT.ynet.sk>
 <26709175.701327480995351.JavaMail.root@5-MeO-DMT.ynet.sk> <20120125.213609.1699401522361877843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120125.213609.1699401522361877843.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/26 David Miller <davem@davemloft.net>:
> From: Stefan Gula <steweg@ynet.sk>
> Date: Wed, 25 Jan 2012 09:43:15 +0100 (CET)
>
>> From: Stefan Gula <steweg@gmail.com>
>>
>> This patch extends the rtnetlink.c. The problem is that calcit, whic=
h
>> returns the value min_ifinfo_dump_size, is called without ability to
>> get device info as well (struct net_device *dev is not accessible fr=
om
>> it). This create a problem if required size of struct sk_buff *skb i=
s
>> not enough big to comply with all data returned by fill_info functio=
n
0>> for the interface that required size can vary over time, e.g. some
>> dynamic structures will be putted to skb like hlists or lists. To do
>> this patch extends the do_setlink function with recalculating of
>> min_ifinfo_dump_size accordingly to device type and get_size
>> functions.
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>
> This commit message is terrible, and the reason I know it's terrible
> is because even after reading it I still had to go read the code
> in order to understand what your change even does or why it's even
> necessary.
>
> How about this:
>
> =A0 =A0 =A0 =A0Setting link parameters on a netdevice changes the val=
ue
> =A0 =A0 =A0 =A0of if_nlmsg_size(), therefore it is necessary to recal=
culate
> =A0 =A0 =A0 =A0min_ifinfo_dump_size.
>
Sound good... do I have to resubmit the patch with the correct descript=
ion?

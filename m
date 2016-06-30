From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Thu, 30 Jun 2016 10:08:28 -0700
Message-ID: <CAM_iQpVijBedKTnU3A4Oa5tWn_qHDEDmJ4aHXH-7bB4xmU_2DA@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
 <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
 <CAJ3xEMhgyvq2_ZsipQ_iFcC6Ef65hj2rkZ0U5scGvj4-=eNkLA@mail.gmail.com>
 <CAM_iQpVPp3YYpfjGmYzBi=i1ONeOT+eLd-P67KuGpHGUmcCZNA@mail.gmail.com> <ca13266f-4cd9-3ac1-9092-9142475cbce9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33674 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbcF3RIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 13:08:48 -0400
Received: by mail-qk0-f176.google.com with SMTP id o76so43561531qke.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:08:48 -0700 (PDT)
In-Reply-To: <ca13266f-4cd9-3ac1-9092-9142475cbce9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 7:23 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
> Hi Cong,
>
>> See below. Does commit f8c6455bb04b944edb69e rely on any firmware
>> change to get an expected checksum?
>>
>> $ lspci -nn | grep -i mellanox
>> 82:00.0 Ethernet controller [0200]: Mellanox Technologies MT27500
>> Family [ConnectX-3] [15b3:1003]
>>
>> $ ethtool -i eth0
>> driver: mlx4_en
>> version: 2.2-1 (Feb 2014)
>> firmware-version: 2.33.5220
>> bus-info: 0000:82:00.0
>
> I used same HW and FW, but was not able to reproduce.
> I have kernel HEAD of net-next: 8a79813c1401 net: ethernet: dwc_eth_qos: use
> phy_ethtool_{get|set}_link_ksettings
>
> I ran regular ping, and ping6. Checksum complete counter increases, but no
> warnings in dmesg.

Thanks for testing it! This helps me a lot to identify the real bug.
Actually the bug is in mirred action instead of mlx4 driver, I have
a patch and just confirmed it fixes the bug. I will send it out in a
few minutes.

Again, thanks a lot for your help!

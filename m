From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Wed, 02 Dec 2015 23:56:53 +0100
Message-ID: <87h9k01mtm.fsf@free-electrons.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<87lh9f4dbt.fsf@free-electrons.com>
	<CAPv3WKc+HbirDxKy5n6W5O5BUTDEc3X5et5dTKdp81WOXjphGg@mail.gmail.com>
	<874mg248jf.fsf@free-electrons.com>
	<CAPv3WKc8VrgH+aAfHBMwvuOxP17SnXCajtzpxmXf4rt+WFcE-w@mail.gmail.com>
	<CAPv3WKdAhk71HW8nvMWXUApySE5_WNgx4PDrj4+R4Tv6FVGNqA@mail.gmail.com>
	<87si3l2kx5.fsf@free-electrons.com>
	<87two0254c.fsf@free-electrons.com>
	<CAPv3WKdHu5O2KEHYpWBHbkA2hHd_QCUK12EBggMDsa8J8D5U2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>, netdev@vger.kernel.org,
	Simon Guinot <simon.guinot@sequanux.org>,
	linux-kernel@vger.kernel.org, Evan Wang <xswang@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>, nitroshift@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKdHu5O2KEHYpWBHbkA2hHd_QCUK12EBggMDsa8J8D5U2Q@mail.gmail.com>
	(Marcin Wojtas's message of "Wed, 2 Dec 2015 23:15:23 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
=20
 On mer., d=C3=A9c. 02 2015, Marcin Wojtas <mw@semihalf.com> wrote:
>>>
>>>> 2. Change condition in mvebu_mbus_get_dram_win_info to:
>>>> if (cs->base <=3D phyaddr && phyaddr <=3D (cs->base + cs->size -1)=
)
>>>
>>> I think it would be the best solution.
>>
>> So I applied the following patch:
>> --- a/drivers/bus/mvebu-mbus.c
>> +++ b/drivers/bus/mvebu-mbus.c
>> @@ -964,7 +964,7 @@ int mvebu_mbus_get_dram_win_info(phys_addr_t phy=
addr, u8 *target, u8 *attr)
>>         for (i =3D 0; i < dram->num_cs; i++) {
>>                 const struct mbus_dram_window *cs =3D dram->cs + i;
>>
>> -               if (cs->base <=3D phyaddr && phyaddr <=3D (cs->base =
+ cs->size)) {
>> +               if (cs->base <=3D phyaddr && phyaddr <=3D (cs->base =
+ cs->size - 1)) {
>>                         *target =3D dram->mbus_dram_target_id;
>>                         *attr =3D cs->mbus_attr;
>>                         return 0;
>>
>> I didn't get any errors during boot related to the BM. However I did=
 not
>> manage to use an ethernet interface. The udhcpc never managed to get=
 an
>> IP and if I set the IP manually I could not ping.
>>
>> But on Armada 388 GP I didn't have any issue.
>>
>> Do you have some idea about waht I could check?
>>
>
> I replaced 2GB with 8GB DIMM and after that, on the same kernel/board=
,
> I can't ping either. Very strange, but as I can reproduce the issue,
> don't debug it, I will.

Thanks to care about it!


Gregory

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com

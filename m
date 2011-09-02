From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: linux-next 20110831 - netconsole startup issue
Date: Fri, 2 Sep 2011 13:54:32 +0800
Message-ID: <CAM_iQpUVVr70xU1uQBDNvCkewCeWwXmdr8dEZ4Z1-SdSfj03Lg@mail.gmail.com>
References: <5187.1314890079@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5187.1314890079@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 1, 2011 at 11:14 PM,  <Valdis.Kletnieks@vt.edu> wrote:
> Chasing a kernel panic in linux-next, and hit an unrelated issue
> starting up netconsole that's bogging me down.
>
> On linux-next-20110823, I had this:
>
> [ =C2=A0 =C2=A07.078099] e1000e: Intel(R) PRO/1000 Network Driver - 1=
=2E5.1-k
> [ =C2=A0 =C2=A07.078102] e1000e: Copyright(c) 1999 - 2011 Intel Corpo=
ration.
> [ =C2=A0 =C2=A07.078158] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (le=
vel, low) -> IRQ 22
> [ =C2=A0 =C2=A07.078171] e1000e 0000:00:19.0: setting latency timer t=
o 64
> [ =C2=A0 =C2=A07.078354] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
> [ =C2=A0 =C2=A07.269439] e1000e 0000:00:19.0: eth0: (PCI Express:2.5G=
T/s:Width x1) 00:21:70:de:b6:fd
> [ =C2=A0 =C2=A07.269443] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000=
 Network Connection
> [ =C2=A0 =C2=A07.269469] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, P=
BA No: 4003FF-0FF
> [ =C2=A0 =C2=A07.293569] netconsole: network logging started
>
> Bring up the ethernet, then the console. Works great,
>
> However, on -20110831, I get this:
>
> [ =C2=A0 =C2=A00.983149] netconsole: local port 9909
> [ =C2=A0 =C2=A00.983254] netconsole: local IP 128.173.14.107
> [ =C2=A0 =C2=A00.983358] netconsole: interface 'eth0'
> [ =C2=A0 =C2=A00.983461] netconsole: remote port 9909
> [ =C2=A0 =C2=A00.983564] netconsole: remote IP 128.173.14.108
> [ =C2=A0 =C2=A00.983668] netconsole: remote ethernet address 00:14:22=
:5a:79:d3
> [ =C2=A0 =C2=A00.983776] netconsole: eth0 doesn't exist, aborting.
> [ =C2=A0 =C2=A00.983897] netconsole: cleaning up
> [ =C2=A0 =C2=A01.176429] e1000e 0000:00:19.0: eth0: (PCI Express:2.5G=
T/s:Width x1) 00:21:70:de:b6:fd
> [ =C2=A0 =C2=A01.176557] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000=
 Network Connection
> [ =C2=A0 =C2=A01.176688] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, P=
BA No: 4003FF-0FF
>
> Whoops. No netconsole.

This is because your eth0 came up after netconsole, I guess
you need to wait for some seconds to let eth0 come up before
activating netconsole.

But I don't see any changes of netconsole between 20110823
and 20110831...

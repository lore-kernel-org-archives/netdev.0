From: Tom Herbert <therbert@google.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Tue, 29 May 2012 07:54:22 -0700
Message-ID: <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33964 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347Ab2E2OyX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 10:54:23 -0400
Received: by yenm10 with SMTP id m10so2101897yen.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 07:54:23 -0700 (PDT)
In-Reply-To: <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Hiroaki for this description, it looks promising.  Denys, can
you test with his patch.

Tom

On Tue, May 29, 2012 at 7:25 AM, Hiroaki SHIMODA
<shimoda.hiroaki@gmail.com> wrote:
> On Sun, 20 May 2012 10:40:41 -0700
> Tom Herbert <therbert@google.com> wrote:
>
>> Tried to reproduce:
>>
>> May 20 10:08:30 test kernel: [ =A0 =A06.168240] e1000e 0000:06:00.0:
>> (unregistered net_device): Interrupt Throttling Rate (ints/sec) set =
to
>> dynamic conservative mode
>> May 20 10:08:30 test kernel: [ =A0 =A06.221591] e1000e 0000:06:00.1:
>> (unregistered net_device): Interrupt Throttling Rate (ints/sec) set =
to
>> dynamic conservative mode
>>
>> 06:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
>> Ethernet Controller (Copper) (rev 01)
>> 06:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
>> Ethernet Controller (Copper) (rev 01)
>>
>> Following above instructions to repro gives:
>>
>> 1480 bytes from test2 (192.168.2.49): icmp_req=3D5875 ttl=3D64 time=3D=
0.358 ms
>> 1480 bytes from test2 (192.168.2.49): icmp_req=3D5876 ttl=3D64 time=3D=
0.330 ms
>> 1480 bytes from test2 (192.168.2.49): icmp_req=3D5877 ttl=3D64 time=3D=
0.337 ms
>> 1480 bytes from test2 (192.168.2.49): icmp_req=3D5878 ttl=3D64 time=3D=
0.375 ms
>> 1480 bytes from test2 (192.168.2.49): icmp_req=3D5879 ttl=3D64 time=3D=
0.359 ms
>> 1480 bytes from lpb49.prod.google.com (192.168.2.49): icmp_req=3D588=
0
>> ttl=3D64 time=3D0.380 ms
>>
>> And I didn't see the stalls. This was on an Intel machine. =A0The li=
mit
>> was stable, went up to around 28K when opened large file and tended =
to
>> stay between 15-28K.
>>
>> The describe problem seems to have characteristics that transmit
>> interrupts are not at all periodic, and it would seem that some are
>> taking hundreds of milliseconds to pop. =A0I don't see anything that
>> would cause that in the NIC, is it possible there is some activity o=
n
>> the machines periodically and often holding down interrupts for =A0l=
ong
>> periods of time. =A0Are there any peculiarities on Sun Fire in inter=
rupt
>> handling?
>>
>> Can you also provide an 'ethtool -c eth0'
>>
>> Thanks,
>> Tom
>
> I also observed the similar behaviour on the following environment.
>
> 03:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network=
 Connection
>
> [ =A0 =A02.962119] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
> [ =A0 =A02.968095] e1000e: Copyright(c) 1999 - 2012 Intel Corporation=
=2E
> [ =A0 =A02.974251] e1000e 0000:03:00.0: Disabling ASPM L0s L1
> [ =A0 =A02.979653] e1000e 0000:03:00.0: (unregistered net_device): In=
terrupt Throttling Rate (ints/sec) set to dynamic conservative mode
> [ =A0 =A02.991599] e1000e 0000:03:00.0: irq 72 for MSI/MSI-X
> [ =A0 =A02.991606] e1000e 0000:03:00.0: irq 73 for MSI/MSI-X
> [ =A0 =A02.991611] e1000e 0000:03:00.0: irq 74 for MSI/MSI-X
> [ =A0 =A03.092768] e1000e 0000:03:00.0: eth0: (PCI Express:2.5GT/s:Wi=
dth x1) 48:5b:39:75:91:bd
> [ 3.100992] e1000e 0000:03:00.0: eth0: Intel(R) PRO/1000 Network Conn=
ection
> [ 3.108173] e1000e 0000:03:00.0: eth0: MAC: 3, PHY: 8, PBA No: FFFFFF=
-0FF
>
> I tried some coalesce options by 'ethtool -C eth0', but
> anything didn't help.
>
> If I understand the code and spec correctly, TX interrupts are
> generated when TXDCTL.WTHRESH descriptors have been accumulated
> and write backed.
>
> I tentatively changed the TXDCTL.WTHRESH to 1, then it seems
> that latency spikes are disappear.
>
> drivers/net/ethernet/intel/e1000e/e1000.h
> @@ -181,7 +181,7 @@ struct e1000_info;
> =A0#define E1000_TXDCTL_DMA_BURST_ENABLE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0(E1000_TXDCTL_GRAN | /* set descriptor granularity */ =
=A0\
> =A0 =A0 =A0 =A0 E1000_TXDCTL_COUNT_DESC | =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 =A0(5 << 16) | /* wthresh must be +1 more than desired =
*/\
> + =A0 =A0 =A0 =A0(1 << 16) | /* wthresh must be +1 more than desired =
*/\
> =A0 =A0 =A0 =A0 (1 << 8) =A0| /* hthresh */ =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 0x1f) =A0 =A0 =A0 /* pthresh */
>
> (before) $ ping -i0.2 192.168.11.2
> PING 192.168.11.2 (192.168.11.2) 56(84) bytes of data.
> 64 bytes from 192.168.11.2: icmp_req=3D1 ttl=3D64 time=3D0.191 ms
> 64 bytes from 192.168.11.2: icmp_req=3D2 ttl=3D64 time=3D0.179 ms
> 64 bytes from 192.168.11.2: icmp_req=3D3 ttl=3D64 time=3D0.199 ms
> 64 bytes from 192.168.11.2: icmp_req=3D4 ttl=3D64 time=3D0.143 ms
> 64 bytes from 192.168.11.2: icmp_req=3D5 ttl=3D64 time=3D0.193 ms
> 64 bytes from 192.168.11.2: icmp_req=3D6 ttl=3D64 time=3D0.150 ms
> 64 bytes from 192.168.11.2: icmp_req=3D7 ttl=3D64 time=3D0.186 ms
> 64 bytes from 192.168.11.2: icmp_req=3D8 ttl=3D64 time=3D0.198 ms
> 64 bytes from 192.168.11.2: icmp_req=3D9 ttl=3D64 time=3D0.195 ms
> 64 bytes from 192.168.11.2: icmp_req=3D10 ttl=3D64 time=3D0.194 ms
> 64 bytes from 192.168.11.2: icmp_req=3D11 ttl=3D64 time=3D0.196 ms
> 64 bytes from 192.168.11.2: icmp_req=3D12 ttl=3D64 time=3D0.200 ms
> 64 bytes from 192.168.11.2: icmp_req=3D13 ttl=3D64 time=3D651 ms
> 64 bytes from 192.168.11.2: icmp_req=3D14 ttl=3D64 time=3D451 ms
> 64 bytes from 192.168.11.2: icmp_req=3D15 ttl=3D64 time=3D241 ms
> 64 bytes from 192.168.11.2: icmp_req=3D16 ttl=3D64 time=3D31.3 ms
> 64 bytes from 192.168.11.2: icmp_req=3D17 ttl=3D64 time=3D0.184 ms
> 64 bytes from 192.168.11.2: icmp_req=3D18 ttl=3D64 time=3D0.199 ms
> 64 bytes from 192.168.11.2: icmp_req=3D19 ttl=3D64 time=3D0.197 ms
> 64 bytes from 192.168.11.2: icmp_req=3D20 ttl=3D64 time=3D0.196 ms
> 64 bytes from 192.168.11.2: icmp_req=3D21 ttl=3D64 time=3D0.192 ms
> 64 bytes from 192.168.11.2: icmp_req=3D22 ttl=3D64 time=3D0.205 ms
> 64 bytes from 192.168.11.2: icmp_req=3D23 ttl=3D64 time=3D629 ms
> 64 bytes from 192.168.11.2: icmp_req=3D24 ttl=3D64 time=3D419 ms
> 64 bytes from 192.168.11.2: icmp_req=3D25 ttl=3D64 time=3D209 ms
> 64 bytes from 192.168.11.2: icmp_req=3D26 ttl=3D64 time=3D0.280 ms
> 64 bytes from 192.168.11.2: icmp_req=3D27 ttl=3D64 time=3D0.193 ms
> 64 bytes from 192.168.11.2: icmp_req=3D28 ttl=3D64 time=3D0.194 ms
> 64 bytes from 192.168.11.2: icmp_req=3D29 ttl=3D64 time=3D0.143 ms
> 64 bytes from 192.168.11.2: icmp_req=3D30 ttl=3D64 time=3D0.191 ms
> 64 bytes from 192.168.11.2: icmp_req=3D31 ttl=3D64 time=3D0.144 ms
> 64 bytes from 192.168.11.2: icmp_req=3D32 ttl=3D64 time=3D0.192 ms
> 64 bytes from 192.168.11.2: icmp_req=3D33 ttl=3D64 time=3D0.199 ms
> 64 bytes from 192.168.11.2: icmp_req=3D34 ttl=3D64 time=3D0.193 ms
> 64 bytes from 192.168.11.2: icmp_req=3D35 ttl=3D64 time=3D0.196 ms
> 64 bytes from 192.168.11.2: icmp_req=3D36 ttl=3D64 time=3D0.196 ms
> 64 bytes from 192.168.11.2: icmp_req=3D37 ttl=3D64 time=3D0.196 ms
> 64 bytes from 192.168.11.2: icmp_req=3D38 ttl=3D64 time=3D1600 ms
> 64 bytes from 192.168.11.2: icmp_req=3D39 ttl=3D64 time=3D1390 ms
> 64 bytes from 192.168.11.2: icmp_req=3D40 ttl=3D64 time=3D1180 ms
> 64 bytes from 192.168.11.2: icmp_req=3D41 ttl=3D64 time=3D980 ms
> 64 bytes from 192.168.11.2: icmp_req=3D42 ttl=3D64 time=3D780 ms
> 64 bytes from 192.168.11.2: icmp_req=3D43 ttl=3D64 time=3D570 ms
> 64 bytes from 192.168.11.2: icmp_req=3D44 ttl=3D64 time=3D0.151 ms
> 64 bytes from 192.168.11.2: icmp_req=3D45 ttl=3D64 time=3D0.189 ms
> 64 bytes from 192.168.11.2: icmp_req=3D46 ttl=3D64 time=3D0.203 ms
> 64 bytes from 192.168.11.2: icmp_req=3D47 ttl=3D64 time=3D0.185 ms
> 64 bytes from 192.168.11.2: icmp_req=3D48 ttl=3D64 time=3D0.189 ms
> 64 bytes from 192.168.11.2: icmp_req=3D49 ttl=3D64 time=3D0.204 ms
> 64 bytes from 192.168.11.2: icmp_req=3D50 ttl=3D64 time=3D0.198 ms
>
> I think 1000 ms - 2000 ms delay is come from e1000_watchdog_task().
>
> (after) $ ping -i0.2 192.168.11.2
> 64 bytes from 192.168.11.2: icmp_req=3D1 ttl=3D64 time=3D0.175 ms
> 64 bytes from 192.168.11.2: icmp_req=3D2 ttl=3D64 time=3D0.203 ms
> 64 bytes from 192.168.11.2: icmp_req=3D3 ttl=3D64 time=3D0.196 ms
> 64 bytes from 192.168.11.2: icmp_req=3D4 ttl=3D64 time=3D0.197 ms
> 64 bytes from 192.168.11.2: icmp_req=3D5 ttl=3D64 time=3D0.186 ms
> 64 bytes from 192.168.11.2: icmp_req=3D6 ttl=3D64 time=3D0.197 ms
> 64 bytes from 192.168.11.2: icmp_req=3D7 ttl=3D64 time=3D0.189 ms
> 64 bytes from 192.168.11.2: icmp_req=3D8 ttl=3D64 time=3D0.146 ms
> 64 bytes from 192.168.11.2: icmp_req=3D9 ttl=3D64 time=3D0.193 ms
> 64 bytes from 192.168.11.2: icmp_req=3D10 ttl=3D64 time=3D0.194 ms
> 64 bytes from 192.168.11.2: icmp_req=3D11 ttl=3D64 time=3D0.195 ms
> 64 bytes from 192.168.11.2: icmp_req=3D12 ttl=3D64 time=3D0.190 ms
> 64 bytes from 192.168.11.2: icmp_req=3D13 ttl=3D64 time=3D0.204 ms
> 64 bytes from 192.168.11.2: icmp_req=3D14 ttl=3D64 time=3D0.201 ms
> 64 bytes from 192.168.11.2: icmp_req=3D15 ttl=3D64 time=3D0.189 ms
> 64 bytes from 192.168.11.2: icmp_req=3D16 ttl=3D64 time=3D0.193 ms
> 64 bytes from 192.168.11.2: icmp_req=3D17 ttl=3D64 time=3D0.190 ms
> 64 bytes from 192.168.11.2: icmp_req=3D18 ttl=3D64 time=3D0.143 ms
> 64 bytes from 192.168.11.2: icmp_req=3D19 ttl=3D64 time=3D0.191 ms
> 64 bytes from 192.168.11.2: icmp_req=3D20 ttl=3D64 time=3D0.190 ms

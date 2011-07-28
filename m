From: hubert Liao <liao.hubertt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Oops when insmod rtl8192ce
Date: Thu, 28 Jul 2011 09:21:23 +0800
Message-ID: <CAMzZzFHoQV9wo31sbEMUOv-OQZE1p1WfT8WMGnKJVjNHKvLmQw@mail.gmail.com>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>
	<CAMzZzFGpDiFAhsLAb+SQxjbGMzBoOStF_Lr7Eb3PT6Drcf=VdA@mail.gmail.com>
	<4E302299.2070309@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E302299.2070309-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2011/7/27 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>:
> On 07/27/2011 04:26 AM, hubert Liao wrote:
>>
>> Hi,
>> We got an oops when insmod rtl8192ce module (the board is an ARM soc=
),
>> accroding the oops message, find it's because in rtl_pci_probe()
>> called _rtl_pci_find_adapter(),
>> in this funcation, the =A0pdev->bus->self is a NULL pointer .
>> static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ieee80211_hw *hw)
>> {
>> struct pci_dev *bridge_pdev =3D pdev->bus->self; =A0 //line 1601
>> ...
>> pcipriv->ndis_adapter.pcibridge_vendorid =3D bridge_pdev->vendor;<--
>> [oops here] line 1700
>> ...
>> }
>> here, I just want to know why the bus->self =A0is NULL?
>> ----
>> [ =A0148.186632] Unable to handle kernel NULL pointer dereference at
>> virtual address 00000020
>
> As John Linville suggested, please open a bugzilla report.
>
Ok, I'll try it, but I am not familiar with it.
> I would also like some additional information. What kernel are you us=
ing? In
> addition, please post the 'lspci -nnk' information for your card.
>
The kernel is from the latest linus kernel git tree(3.0.0-05684-ge371d4=
6-dirty),
I also have tested the 2.6.38.8 stable release, it has the same problem=
=2E

lspci -nnk
00:00.0 Class [0580]: Device [11ab:6192] (rev 03)
        Subsystem: Device [11ab:11ab]
00:01.0 Class [0280]: Device [10ec:8178] (rev 01)
        Subsystem: Device [1a3b:1178]

> I also think that pdev->bus should have been setup before the initial=
ization
> code in rtl8192ce was called. I have not tested the driver on other t=
han x86
> and x86_64 architectures because of hardware availability, thus ARM m=
ay
> expose some problems. Is this soc little-endian?
>
Yes ,it is little-endian

cat /proc/cpuinfo
Processor       : Feroceon 88FR131 rev 1 (v5l)
BogoMIPS        : 789.70
=46eatures        : swp half thumb fastmult edsp
CPU implementer : 0x56
CPU architecture: 5TE
CPU variant     : 0x2
CPU part        : 0x131
CPU revision    : 1

Hardware        : Marvell RD-88F6192-NAS Development Board
Revision        : 0000
Serial          : 0000000000000000

> Thanks,
> Larry
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

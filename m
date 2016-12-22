From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: Re: [PATCH net-next] ixgbevf: fix 'Etherleak' in ixgbevf
Date: Thu, 22 Dec 2016 10:00:50 +0800
Message-ID: <74e1e76d-40f6-db8e-74ac-90b0474d4e11@huawei.com>
References: <1481802034-77729-1-git-send-email-chenweilong@huawei.com>
 <CAKgT0UfA9VG4NQZLLxXvobtfp22yPpPssSM4Ge94KFa1RVnhyg@mail.gmail.com>
 <5c942aba-f7fb-ede6-b6a2-e591025f53a5@huawei.com>
 <CAKgT0Uf_HXtJiZJsEYm9L19cZ+deVX=E+Y8JvU5+u0=bggpAqw@mail.gmail.com>
 <ee9ad90d-1c4b-7358-a172-8369a0c7da8b@huawei.com>
 <CAKgT0Uf+hV=TDvNTqFz0aiKQ+iio7VhBc5pusc4aDtFAVbREpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Weilong Chen <chenweilong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0Uf+hV=TDvNTqFz0aiKQ+iio7VhBc5pusc4aDtFAVbREpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/12/21 10:20, Alexander Duyck wrote:
> I find it curious that only the last 4 bytes have data in them.  I'm
> wondering if the NIC/driver in the Windows/Nessus system is
> interpreting the 4 byte CRC on the end of the frame as padding instead
> of stripping it.
> 
> Is there any chance you could capture the entire frame instead of just
> the padding?  Maybe you could run something like wireshark without
> enabling promiscuous mode on the VF and capture the frames it is
> trying to send and receive.  What I want to verify is what the actual
> amount of padding is that is needed to get to 60 bytes and where the
> CRC should start.
> 
> - Alex

Here is the verbose output, is this useful?
Or we will try according to your advice, thanks,

D:\Program Files\Tenable\Nessus>nasl.exe -aX -t 192.169.0.151 etherleak.nasl
--------------------------
 ---[ ICMP ]---
0x00:  45 00 00 1D 20 81 00 00 40 01 D7 F3 C0 A9 00 97    E... ...@.......
0x10:  C0 A9 00 82 00 00 87 FD 00 01 00 01 78 00 00 00    ............x...
0x20:  00 00 00 00 00 00 00 00 00 00 98 E4 75 DF          ............u.
--------------------------
 ---[ ICMP ]---
0x00:  45 00 00 1D 20 85 00 00 40 01 D7 EF C0 A9 00 97    E... ...@.......
0x10:  C0 A9 00 82 00 00 87 FD 00 01 00 01 78 00 00 00    ............x...
0x20:  00 00 00 00 00 00 00 00 00 00 FB DA F8 13          ..............
---[ ether1 ]---
0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 98 E4 75    ...............u
0x10:  DF                                                 .
---[ ether2 ]---
0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 FB DA F8    ................
0x10:  13                                                 .

Padding observed in one frame :

  0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 98 E4 75    ...............u
  0x10:  DF                                                 .

Padding observed in another frame :

  0x00:  00 00 00 00 00 00 00 00 00 00 00 00 00 FB DA F8    ................
  0x10:  13

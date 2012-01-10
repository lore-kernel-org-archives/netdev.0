From: Grant Grundler <grundler@chromium.org>
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy init
 for AX88772 USB ethernet".
Date: Mon, 9 Jan 2012 17:38:02 -0800
Message-ID: <CANEJEGsG_s3pLaax62SnSWEvtARzxq6GZys0OE_ps6H-jfY7Qw@mail.gmail.com>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
	<CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com>
	<20120108171802.287811bpiixnymys@www.81.fi>
	<CANEJEGsUOzpb_Cg0DfDX8ftMZr9fhAMGc7ba9yJCKkQ6Vvhe+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
	Olof Johansson <olofj@chromium.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Hollis <dhollis@davehollis.com>,
	Allan Chou <allan@asix.com.tw>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:38049 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932283Ab2AJBiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 20:38:04 -0500
Received: by obcwo16 with SMTP id wo16so4910828obc.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 17:38:03 -0800 (PST)
In-Reply-To: <CANEJEGsUOzpb_Cg0DfDX8ftMZr9fhAMGc7ba9yJCKkQ6Vvhe+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2012 at 9:21 AM, Grant Grundler <grundler@chromium.org> wrote:
...
>> Patch attached.
>
> I'll try the patch here to confirm. Thanks!

Jussi,
I can confirm you patch doesn't break my basic use case:
  Acked-By: Grant Grundler <grundler@chromium.org>


localhost ~ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:00:00:00:08:b3
          inet addr:XX.XX.XX.1  Bcast:XX.XX.XX.255  Mask:255.255.252.0
...
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:500 errors:0 dropped:19 overruns:0 frame:0
          TX packets:320 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:110020 (107.4 KiB)  TX bytes:43569 (42.5 KiB)

localhost ~ # dmesg | fgrep eth0
[    2.049163] asix 1-4:1.0: eth0: register 'asix' at
usb-0000:00:1d.7-4, ASIX AX88772 USB 2.0 Ethernet, 00:00:00:00:08:b3
[    3.693169] ADDRCONF(NETDEV_UP): eth0: link is not ready
[    5.515078] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    5.518469] asix 1-4:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0xCDE1
localhost ~ #

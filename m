From: Grant Grundler <grundler@chromium.org>
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy init
 for AX88772 USB ethernet".
Date: Fri, 6 Jan 2012 09:33:47 -0800
Message-ID: <CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
	Olof Johansson <olofj@chromium.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Hollis <dhollis@davehollis.com>,
	Allan Chou <allan@asix.com.tw>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:60024 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758864Ab2AFRds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 12:33:48 -0500
Received: by obcwo16 with SMTP id wo16so2124550obc.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 09:33:47 -0800 (PST)
In-Reply-To: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 3:10 AM, Jussi Kivilinna
<jussi.kivilinna@mbnet.fi> wrote:
> Hello,
>
> I have asix adapter plugged to mini-server

Which Asix adapter do you have? (Vendor/model)

Can you please provide:
1) dmesg output from asix driver
2) lsusb output for the device

> and have to change MAC address
> before DHCP because of ISP. This worked fine, until v3.2. Now I have to set
> interface in promisc mode to have custom MAC working.

Sorry - I didn't test this but I also would not expect this to break
with the changes in 3.2.

I'll see if Freddy or Allan (ASIX) need my help with this.

cheers,
grant

>
> I bisected problem to '[4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378] NET: fix
> phy init for AX88772 USB ethernet':
>
> # bad: [5f0a6e2d503896062f641639dacfe5055c2f593b] Linux 3.2-rc7
> # good: [c3b92c8787367a8bb53d57d9789b558f1295cc96] Linux 3.1
> git bisect start 'v3.2-rc7' 'v3.1' 'drivers/net/usb/asix.c'
> # bad: [79de9efdb93d8e693dccd0eb7d80cd6092f5875b] NET: asix: fix ethtool -e
> for AX88178 USB dongle
> git bisect bad 79de9efdb93d8e693dccd0eb7d80cd6092f5875b
> # bad: [4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378] NET: fix phy init for
> AX88772 USB ethernet
> git bisect bad 4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378
> # good: [afc4b13df143122f99a0eb10bfefb216c2806de0] net: remove use of
> ndo_set_multicast_list in drivers
> git bisect good afc4b13df143122f99a0eb10bfefb216c2806de0
>
> -Jussi
>

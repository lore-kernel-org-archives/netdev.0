From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Regression: netlink fail (triggered by iw) removes extra wlan
 (phy) interface
Date: Wed, 16 Mar 2016 09:00:55 -0700
Message-ID: <CAM_iQpW_63Di76BcnSF35h1+ezxv8G62NT0U=tWFFe6n9FaNig@mail.gmail.com>
References: <CACna6rzz4f-urvD7uvVKuvYMOWhW+JYWkVW8MK9mJTPw0OiWxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>, Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Martin KaFai Lau <kafai@fb.com>,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:33720 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbcCPQBJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 12:01:09 -0400
In-Reply-To: <CACna6rzz4f-urvD7uvVKuvYMOWhW+JYWkVW8MK9mJTPw0OiWxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 5:22 AM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.=
com> wrote:
> Hi,
>
> After updating kernel in OpenWrt from 4.1.6 to 4.1.10 I noticed that
> if "iw" command fails (which happens very rarely) my wlan0-1 interfac=
e
> disappears. To trigger this problem easily I'm using this trivial
> script:
> while [ 1 ]
> do
>         iw phy phy0 interface add mon0 type monitor
>         ifconfig mon0 up
>         iw dev mon0 del
> done
>
> Whenever it goes wrong I see:
> Failed to connect to generic netlink.
> kern.info kernel: [ 1933.114338] br-lan: port 3(wlan0-1) entered disa=
bled state
> kern.info kernel: [ 1933.335568] device wlan0-1 left promiscuous mode
> kern.info kernel: [ 1933.340385] br-lan: port 3(wlan0-1) entered disa=
bled state
> daemon.notice netifd: Network device 'wlan0-1' link is down
> command failed: Too many open files in system (-23)
>

Note, for 4.1, the backport is known to be incorrect, and it is
fixed later by:

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/co=
mmit/net/netlink/af_netlink.c?h=3Dlinux-4.1.y&id=3Da52ec6de6d1638e8c203=
d7188c55627f75371612


> This regression is caused by commit:
> 4e27762 netlink: Fix autobind race condition that leads to zero port =
ID
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/=
commit/?id=3D4e27762417669cb459971635be550eb7b5598286
> that is a backport of upstream:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3D1f770c0a09da855a2b51af6d19de97fb955eca85
>
> This still happens with kernel 4.4.


Looks like the goto is missing in 4.4 branch too. ;) Mind to send a pat=
ch
to GregKH?


>
> My hardware is Linksys WRT160NL (Atheros AR9130 SoC) and I'm using tw=
o
> __ap interfaces on phy0 (wlan0 and wlan0-1).
>
> Could you take a look at this?
> Is there some additional info I could provide to help fixing this?
>
> --
> Rafa=C5=82

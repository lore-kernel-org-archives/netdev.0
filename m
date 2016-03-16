From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: Regression: netlink fail (triggered by iw) removes extra wlan
 (phy) interface
Date: Wed, 16 Mar 2016 13:00:51 +0100
Message-ID: <CACna6rx84_StJWYKekxw=SD=ReaEyTDFJLGLGeXshU6QVRrPPw@mail.gmail.com>
References: <CACna6rzz4f-urvD7uvVKuvYMOWhW+JYWkVW8MK9mJTPw0OiWxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, kafai@fb.com,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Network Development <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rzz4f-urvD7uvVKuvYMOWhW+JYWkVW8MK9mJTPw0OiWxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25 February 2016 at 14:22, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com=
> wrote:
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
>
> My hardware is Linksys WRT160NL (Atheros AR9130 SoC) and I'm using tw=
o
> __ap interfaces on phy0 (wlan0 and wlan0-1).
>
> Could you take a look at this?
> Is there some additional info I could provide to help fixing this?

Ping?

--=20
Rafa=C5=82

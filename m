From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: Regression: netlink fail (triggered by iw) removes extra wlan
 (phy) interface
Date: Wed, 4 May 2016 15:33:04 +0200
Message-ID: <CACna6rzXwCaYgHTuVHr35NoBDkgT5WjFWE+Ys9YU42KidiZsGw@mail.gmail.com>
References: <CACna6rzz4f-urvD7uvVKuvYMOWhW+JYWkVW8MK9mJTPw0OiWxA@mail.gmail.com>
	<CAM_iQpW_63Di76BcnSF35h1+ezxv8G62NT0U=tWFFe6n9FaNig@mail.gmail.com>
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpW_63Di76BcnSF35h1+ezxv8G62NT0U=tWFFe6n9FaNig@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again and sorry for the late reply.

On 16 March 2016 at 17:00, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Feb 25, 2016 at 5:22 AM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmai=
l.com> wrote:
>> After updating kernel in OpenWrt from 4.1.6 to 4.1.10 I noticed that
>> if "iw" command fails (which happens very rarely) my wlan0-1 interfa=
ce
>> disappears. To trigger this problem easily I'm using this trivial
>> script:
>> while [ 1 ]
>> do
>>         iw phy phy0 interface add mon0 type monitor
>>         ifconfig mon0 up
>>         iw dev mon0 del
>> done
>>
>> Whenever it goes wrong I see:
>> Failed to connect to generic netlink.
>> kern.info kernel: [ 1933.114338] br-lan: port 3(wlan0-1) entered dis=
abled state
>> kern.info kernel: [ 1933.335568] device wlan0-1 left promiscuous mod=
e
>> kern.info kernel: [ 1933.340385] br-lan: port 3(wlan0-1) entered dis=
abled state
>> daemon.notice netifd: Network device 'wlan0-1' link is down
>> command failed: Too many open files in system (-23)
>>
>
> Note, for 4.1, the backport is known to be incorrect, and it is
> fixed later by:
>
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/=
commit/net/netlink/af_netlink.c?h=3Dlinux-4.1.y&id=3Da52ec6de6d1638e8c2=
03d7188c55627f75371612
>
>
>> This regression is caused by commit:
>> 4e27762 netlink: Fix autobind race condition that leads to zero port=
 ID
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git=
/commit/?id=3D4e27762417669cb459971635be550eb7b5598286
>> that is a backport of upstream:
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3D1f770c0a09da855a2b51af6d19de97fb955eca85
>>
>> This still happens with kernel 4.4.
>
>
> Looks like the goto is missing in 4.4 branch too. ;) Mind to send a p=
atch
> to GregKH?

So I just tried kernel 4.1.23 and got that problem again while running
my bash script:

=46ailed to connect to generic netlink.
ifconfig: SIOCGIFFLAGS: No such device
command failed: No such device (-19)
[ 2200.114464] br-lan: port 3(wlan0-1) entered disabled state
[ 2200.125979] device wlan0-1 left promiscuous mode
[ 2200.134529] br-lan: port 3(wlan0-1) entered disabled state
=46ailed to connect to generic netlink.
ifconfig: SIOCGIFFLAGS: No such device
command failed: No such device (-19)

--=20
Rafa=C5=82

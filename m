From: Vasily Averin <vvs@parallels.com>
Subject: Re: bride: IPv6 multicast snooping enhancements
Date: Thu, 12 Feb 2015 15:01:24 +0300
Message-ID: <54DC9614.9060502@parallels.com>
References: <1378253619-23918-1-git-send-email-linus.luessing@web.de> <54D9C4ED.6040601@parallels.com> <20150210114428.GK2489@odroid> <54DA0EAD.60002@parallels.com> <20150212114117.GC3665@odroid>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Cong Wang <amwang@redhat.com>
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@c0d3.blue>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23115 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755288AbbBLMDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2015 07:03:20 -0500
In-Reply-To: <20150212114117.GC3665@odroid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.02.2015 14:41, Linus L=C3=BCssing wrote:
> On Tue, Feb 10, 2015 at 04:59:09PM +0300, Vasily Averin wrote:
>> I'm trying to fix ICMPv6 processing broken in OpenVZ after rebase to=
 last RHEL6u6 kernel.
>> After some unclear manipulation bridge begins to forward icmp6 NS (f=
e02::1) into wrong port,
>> and at present I do not found the reason of this failure.
>=20
> fe02::1 seems uncommon for ICMPv6 NS messages. Would you mind
> making some dumps for ~10 minutes with tcpdump on all bridge ports
> and the bridge interface itself with a filter "icmp6" and uploading t=
he
> result somewhere?
>=20
> Also provide a dump from "bridge mdb show dev $bridge" please (if
> possible - not sure whether that's available on the ancient 2.6.32
> kernel as used on RHEL6u6).

Thank you, "bridge mdb show" helps me to find an external router.

Therefore bridge forwarded all locally generated multicasts to external=
 port.
Then forwarded messages was lost or was filtered or=20
just incorrectly processed, but in any case they never returned back.

So as far as I understand bridge itself works correctly,=20
it isn't responsible for external troubles.

Thank you,
	Vasily Averin

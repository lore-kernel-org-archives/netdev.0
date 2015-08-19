From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Wed, 19 Aug 2015 14:13:00 +0200
Message-ID: <87bne38oj7.fsf@zoro.exoscale.ch>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
	<1439966648-26195-1-git-send-email-vincent@bernat.im>
	<1439966648-26195-2-git-send-email-vincent@bernat.im>
	<20150819130013.1a847627@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:39629 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753596AbbHSMXG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 08:23:06 -0400
In-Reply-To: <20150819130013.1a847627@griffin> (Jiri Benc's message of "Wed,
	19 Aug 2015 13:00:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 19 ao=C3=BBt 2015 13:00 +0200, Jiri Benc <jbenc@redhat.com>=C2=
=A0:

>> While the documentation doesn't say exactly what kind of relationshi=
p
>> iflink should represent, until a45253, only lower devices were
>> advertised this way. While veth cannot have a lower device, using if=
link
>> to advertise the peer may create infinite loops in programs using if=
link
>> to discover device topology.
>>=20
>> Instead of advertising the peer link with iflink, a symbolic link "p=
eer"
>> is added to each peer.
>
> By removing veth_get_iflink, you're also stopping IFLA_LINK being
> advertised in netlink messages, which consequently makes impossible t=
o
> reliably match veth peers across name spaces again. This would be a
> huge step backwards.

That's the main goal of this patch: advertising the peer link as
IFLA_LINK attribute triggers an infinite loop in userland software when
they follow iflink to discover network devices topology. iflink has
always been the index of a lower device. If a sysfs symbolic link is no=
t
good enough, I can propose a new IFLA_PEER attribute instead.
--=20
How apt the poor are to be proud.
		-- William Shakespeare, "Twelfth-Night"

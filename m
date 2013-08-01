From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 1/2] net: fix a compile error when
 CONFIG_NET_LL_RX_POLL is not set
Date: Thu, 01 Aug 2013 16:08:07 +0800
Message-ID: <1375344487.7780.14.camel@cr0>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com>
	 <51FA060A.2060202@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663Ab3HAIIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 04:08:24 -0400
In-Reply-To: <51FA060A.2060202@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 09:54 +0300, Eliezer Tamir wrote:
> On 01/08/2013 06:10, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> >=20
> > When CONFIG_NET_LL_RX_POLL is not set, I got:
> >=20
> > net/socket.c: In function =E2=80=98sock_poll=E2=80=99:
> > net/socket.c:1165:4: error: implicit declaration of function =E2=80=
=98sk_busy_loop=E2=80=99 [-Werror=3Dimplicit-function-declaration]
> >=20
> > Fix this by adding a nop when !CONFIG_NET_LL_RX_POLL.
> >=20
>=20
> Good catch!
>=20
> There is a placeholder function, but it has a typo in the name.
> With all the renaming I made a mistake and called the do-nothing
> function sk_busy_poll while the implemented function is called sk_bus=
y_loop.
>=20
> so what we need is to rename sk_busy_loop() into sk_busy_poll.
>=20

Ok.

Thinking about it again, what is the point of your commit commit
89bf1b5a683df497c572c4d3bd3f9c9aa919d773 (net: remove NET_LL_RX_POLL
config menue)? After that commit, CONFIG_NET_LL_RX_POLL is not visible
by user and no other configs select it, also since it defaults to y, it
will be _always_ enabled. If this is really what you want, we can simpl=
y
remove all !CONFIG_NET_LL_RX_POLL code.

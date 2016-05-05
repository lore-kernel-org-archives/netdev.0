From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: task_diag: add a new interface to get information about
 processes
Date: Wed, 4 May 2016 19:14:36 -0700
Message-ID: <20160504191436.7dfa3a55@xeon-e3>
References: <20160504132245.1d04c131@xeon-e3>
 <CANaxB-w2RZ8WZ0ACP-3M9OJ0vgWRM0d74S2WAVwRRY=gXoR5Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Eric W. Biedermanm" <ebiederm@xmission.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36273 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbcEECOY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 22:14:24 -0400
Received: by mail-pf0-f181.google.com with SMTP id c189so32973729pfb.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 19:14:24 -0700 (PDT)
In-Reply-To: <CANaxB-w2RZ8WZ0ACP-3M9OJ0vgWRM0d74S2WAVwRRY=gXoR5Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 May 2016 15:34:21 -0700
Andrey Vagin <avagin@openvz.org> wrote:

> Hi Stephen,
>=20
> On Wed, May 4, 2016 at 1:22 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > I understand how reading /proc or /sys can be a bottleneck, but thi=
s
> > proposed method using a system call is the wrong way to do this.
> >
> > Why not use netlink like other systems do which allows a message
> > based response which allows for future changes (no fixed datastruct=
ures),
> > and is message based.
> >
> > Generic netlink has already been used by several other subsystems.
>=20
> I used netlink in two first versions of task_diag, but then Andy
> convinced me that netlink interfaces are not ideal for this case. I
> added him into C=D1=81.
>=20
> Here is a thread with our discussion about using netlink for
> task_diag: https://lkml.org/lkml/2015/12/15/520
> Can I ask you to read it and give your comments? It would be nice to
> find a way how to use netlink sockets instead of creating a new
> interface.
>=20
> Thanks,
> Andrew

LKML is too busy, no one reads it anymore :-)
Since this is netlink related you need to discuss it on netdev.

The objection seems to be time or creation versus time of use and permi=
ssions.
Netlink internally is not really message based all responses are genera=
ted
in the context of the send().  You need credentials to create
the socket, but the actual response will occur in the context of the ca=
lling
process. I don't see how that is substantially different than a system =
call.

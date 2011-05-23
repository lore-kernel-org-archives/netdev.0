From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [v3 00/39] faster tree-based sysctl implementation
Date: Mon, 23 May 2011 09:37:35 +0300
Message-ID: <BANLkTinqX_=TLU3TuKJFFTJBBxm1scZ3Ew@mail.gmail.com>
References: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com> <m14o4mavod.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61136 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab1EWGhz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 02:37:55 -0400
In-Reply-To: <m14o4mavod.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 7:27 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> This patchset looks like it is deserving of some close scrutiny, and
> not just the high level design overview I have given the previous
> patches. =C2=A0This is going to be a busy week for me so I probably w=
on't
> get through all of the patches for a while.


I have one more question. The current implementation uses a single
sysctl_lock to synchronize all changes to the data structures.

In my algorithm I change a few places to use a per-header read-write
lock. Even though the code is organized to handle a per-header rwlock,
the implementation uses a single global rwlock. In v2 I got rid of the
rwlock and replaced the subdirs/files regular lists with rcu-protected
lists and that's why I did not bother giving each header a rwlock.


I have no idea how to use rcu with rbtree. Should I now give each
header it's own lock to reduce contention?


I'm asking this because I don't know why the only is a global sysctl
spin lock, when multiple locks could have been used, each to protect
it's own domain of values.

If you'd like to keep locking as simple as possible (to reduce all the
potential problems brought on by too many locks), or if in general
contention is low enough, then global lock is better. If not, then
I'll change the code to support per-header rwlocks (increasing the
ctl_table_header structure size).

--=20
=C2=A0.
=2E.: Lucian

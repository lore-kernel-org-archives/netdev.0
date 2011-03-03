From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: RFC v1: sysctl: add sysctl header cookie, share tables between nets
Date: Thu, 3 Mar 2011 23:32:18 +0100
Message-ID: <AANLkTik_hnW9DEtcYmY9Ne+zGsxWs4q05nXMfdyh13mK@mail.gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
 <20110302.170644.58413369.davem@davemloft.net> <m1zkpc1rbc.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, adobriyan@gmail.com,
	tavi@cs.pub.ro, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1zkpc1rbc.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 3, 2011 at 10:33 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> I may be missing something in these patches. I haven't had time to lo=
ok
> at this most recent batch carefully. =C2=A0But from a 10,000 foot per=
spective I
> have a problem with them. =C2=A0With a handful of network devices the=
 size of
> the data structures is negligible.
>
> So until I can see a reason why we should save a few bytes at the cos=
t
> of greater future maintenance costs I'm not in favor of this patch se=
t.


Sorry, I'm moving between countries and I don't have as much time as
I'd like to.

This patch series adds the "cookie" field and uses it in a few places.
I need this for the next step, but I wanted some feedback regarding
the cookie approach (sane? applicable if the 'dynamic header' feature
is accepted?).

Afterwards I want to add a "dynamic ctl_header" which will implement a
few ops (something on the lines of 'find_in_table' and 'scan' from
proc_sysctl.c).

At 'scan' time the "dynamic header" will create inodes for the
directories underneath with:
  ctl_table=3D'shared ctl table for /proc/sys/net/ipv4/conf' (or
ipv6/addrconf or neigh)
  ctl_table_header=3Da device specific (not dynamic) table header with
->cookie pointing to a struct {char*dev_name; struct net*net;}

proc_handlers will use the name (or even a pointer to the device or
whatever speeds up the implementation) and the net to find out the
real ->data similar to the netns_proc_handlers from this patch series.

Adding an interface will not need to scan through the list of existing
ctl headers to see if any duplicates exist because there cannot be two
interfaces with the same name.

Promise to get back with patches for this implementation as soon as I c=
an.

PS: sorry if my mumbling does not make much sense, hopefully code will
make things clear.
--=20
=C2=A0.
=2E.: Lucian

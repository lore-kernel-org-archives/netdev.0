From: Bodo Eggert <harvested.in.lkml@posting.7eggert.dyndns.org>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Fri, 16 Dec 2005 09:35:20 +0100
Message-ID: <E1EnB3h-0005DP-CW@be1.lrz>
References: <5jUjW-8nu-7@gated-at.bofh.it> <5jWYp-3K1-19@gated-at.bofh.it> <5jXhZ-4kj-19@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932189AbVLPImx@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, dlstevens@us.ibm.com,
	shemminger@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org,
	mpm@selenic.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, sri@us.ibm.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:

> The idea to mark, for example, IPSEC key management daemon's sockets
> as critical is flawed, because the key management daemon could hit a
> swap page over the iSCSI device.  Don't even start with the idea to
> lock the IPSEC key management daemon into ram with mlock().

How are you going to swap in the key manager if you need the key manage=
r
for doing this?


However, I'd prefer a system where you can't dirty mor than (e.g.) 80 %=
 of
RAM unless you need this to maintain vital system activity and not more
than 95 % unless it will help to get more clean RAM. (Like the priority
inheritance suggestion from this thread.) I suppose this to least
significantly reduce thrashing and give a very good chance of recoverin=
g
from memory pressure. Off cause the implementation won't be easy,
especially if userspace applications need to inherit priority from
different code paths, but in theory, it can be done.

--=20
Ich danke GMX daf=FCr, die Verwendung meiner Adressen mittels per SPF
verbreiteten L=FCgen zu sabotieren.

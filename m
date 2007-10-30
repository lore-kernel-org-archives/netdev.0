From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Tue, 30 Oct 2007 14:18:27 +0100
Message-ID: <200710301418.27643.jdelvare@suse.de>
References: <200710261721.32019.jdelvare@suse.de> <20071026153416.GA23491@bingen.suse.de> <20071030.005758.184980120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ak@suse.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47216 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbXJ3NR0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 09:17:26 -0400
In-Reply-To: <20071030.005758.184980120.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Le mardi 30 octobre 2007, David Miller a =E9crit=A0:
> From: Andi Kleen <ak@suse.de>
> Date: Fri, 26 Oct 2007 17:34:17 +0200
>=20
> > On Fri, Oct 26, 2007 at 05:21:31PM +0200, Jean Delvare wrote:
> > > I propose 2 millions of entries as the arbitrary high limit. This
> >=20
> > It's probably still far too large.
>=20
> I agree.  Perhaps a better number is something on the order of
> (512 * 1024) so I think I'll check in a variant of Jean's patch
> with just the limit decreased like that.

That's very fine with me. I originally proposed an admittedly high
limit value to increase the chance to see it accepted. I am not
familiar enough with networking to know what a more reasonable
limit would be, so I'm leaving it to the experts.

> Using just some back of the envelope calculations, on UP 64-bit
> systems each socket uses about 2424 bytes minimum of memory (this is
> the sum of tcp_sock, inode, dentry, socket, and file on sparc64 UP).
> This is an underestimate because it does not even consider things lik=
e
> allocator overhead.
>=20
> Next, machines that service that many sockets typically have them
> mostly with full transmit queues talking to a very slow receiver at
> the other end.  So let's estimate that on average each socket consume=
s
> about 64K of retransmit queue data.
>=20
> I think this is an extremely conservative estimate beause it doesn't
> even consider overhead coming from struct sk_buff and related state.
>=20
> So for (512 * 1024) of established sockets we consume roughly 35GB of
> memory, this is '((2424 + (64 * 1024)) * (512 * 1024))'.
>=20
> So to me (512 * 1024) is a very reasonable limit and (with lockdep
> and spinlock debugging disabled) this makes the EHASH table consume
> 8MB on UP 64-bit and ~12MB on SMP 64-bit systems.

OK, let's go with (512 * 1024) then. Want me to send an updated patch?

Thanks,
--=20
Jean Delvare
Suse L3

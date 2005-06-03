From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Sat, 4 Jun 2005 01:30:21 +0200
Message-ID: <20050603233021.GC21125@xi.wantstofly.org>
References: <20050603.120126.41874584.davem@davemloft.net> <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com> <20050603.132257.23013342.davem@davemloft.net> <20050603.132922.63997492.davem@davemloft.net> <1117828169.4430.29.camel@rh4> <20050603205944.GC20623@xi.wantstofly.org> <20050603210701.GA3263@edgar.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Michael Chan <mchan@broadcom.com>, "David S. Miller" <davem@davemloft.net>,
        mitch.a.williams@intel.com, hadi@cyberus.ca, john.ronciak@intel.com,
        jdmason@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Edgar E Iglesias <edgar.iglesias@axis.com>
Content-Disposition: inline
In-Reply-To: <20050603210701.GA3263@edgar.se.axis.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2005 at 11:07:01PM +0200, Edgar E Iglesias wrote:

> > > Yes, in tg3, rx buffers are replenished and put back into the ring
> > >=A0as completed packets are taken off the ring. But we don't tell th=
e
> > > chip about these new buffers until we get to the end of the loop,
> > > potentially after a full quota of packets.
> >=20
> > Which makes a lot more sense, since you'd rather do one MMIO write
> > at the end of the loop than one per iteration, especially if your
> > MMIO read (flush) latency is high.  (Any subsequent MMIO read will
> > have to flush out all pending writes, which'll be slow if there's
> > a lot of writes still in the queue.)
>=20
> Maybe it would be better to put a fixed weight at this level, return
> the descriptors to the HW after every X packets. That way you
> can keep the NAPI weight at 64 (or what ever) and still give back=20
> descriptors to HW more often.

For this scheme to make any difference at all, the RX ring must be
overflowing in the case where we refill the RX ring only once every
64 packets.

If the RX ring _is_ overflowing but the system is otherwise capable of
keeping up with the receive rate (i.e. the packet service times as seen
by the NIC have a high variance), simply make the RX ring bigger.

I don't see what's going on.


--L

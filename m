From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 22:59:45 +0200
Message-ID: <20050603205944.GC20623@xi.wantstofly.org>
References: <20050603.120126.41874584.davem@davemloft.net> <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com> <20050603.132257.23013342.davem@davemloft.net> <20050603.132922.63997492.davem@davemloft.net> <1117828169.4430.29.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, mitch.a.williams@intel.com,
        hadi@cyberus.ca, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1117828169.4430.29.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2005 at 12:49:29PM -0700, Michael Chan wrote:

> > E1000 processes the full QUOTA of RX packets,
> > _THEN_ replenishes with new RX buffers.  No wonder
> > the chip runs out of RX descriptors.
> >=20
> > You should replenish _AS_ you grab RX packets
> > off the receive queue, just as tg3 does.
>=20
> Yes, in tg3, rx buffers are replenished and put back into the ring
>=A0as completed packets are taken off the ring. But we don't tell the
> chip about these new buffers until we get to the end of the loop,
> potentially after a full quota of packets.

Which makes a lot more sense, since you'd rather do one MMIO write
at the end of the loop than one per iteration, especially if your
MMIO read (flush) latency is high.  (Any subsequent MMIO read will
have to flush out all pending writes, which'll be slow if there's
a lot of writes still in the queue.)


--L

From: P@draigBrady.com
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 10:18:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414808F3.70104@draigBrady.com>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Linux NICS <linux.nics@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> Hi!
>=20
> I'm currently trying to help Robert Olsson improving the performance of
> the Linux in-kernel packet generator (pktgen.c).  At the moment, we see=
m
> to be unable to get more than 760kpps from a single port of a 82546,
> (or any other PCI-X MAC supported by e1000) - that's a bit more than 51=
%
> wirespeed at 64byte packet sizes.

In my experience anything around 750Kpps is a PCI limitation,
specifically PCI bus arbitration latency. Note the clock speed of
the control signal used for bus arbitration has not increased
in proportion to the PCI data clock speed.

The application note #453 referenced below is very imformative:
http://www.intel.com/design/network/products/lan/docs/82546_docs.htm

I was able to confirm the above by passing 4x730Kpps
through a PCI-X system with 4 ethernet controllers,
but never more than 760Kpps through one particular controller.

Note also you may be able to tune for transmission
using setpci (google for setpci & MMRBC), or hacking with TSO?

P=E1draig.

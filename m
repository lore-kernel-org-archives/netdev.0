From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6 1/2] PCI-Express Non-Transparent Bridge Support
Date: Thu, 17 Jan 2013 19:14:04 -0800
Message-ID: <20130118031404.GA13239@kroah.com>
References: <1353119233-32752-1-git-send-email-jon.mason@intel.com>
 <1353119233-32752-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1353119233-32752-2-git-send-email-jon.mason@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 16, 2012 at 07:27:12PM -0700, Jon Mason wrote:
> A PCI-Express non-transparent bridge (NTB) is a point-to-point PCIe b=
us
> connecting 2 systems, providing electrical isolation between the two =
subsystems.
> A non-transparent bridge is functionally similar to a transparent bri=
dge except
> that both sides of the bridge have their own independent address doma=
ins.  The
> host on one side of the bridge will not have the visibility of the co=
mplete
> memory or I/O space on the other side of the bridge.  To communicate =
across the
> non-transparent bridge, each NTB endpoint has one (or more) apertures=
 exposed to
> the local system.  Writes to these apertures are mirrored to memory o=
n the
> remote system.  Communications can also occur through the use of door=
bell
> registers that initiate interrupts to the alternate domain, and scrat=
ch-pad
> registers accessible from both sides.
>=20
> The NTB device driver is needed to configure these memory windows, do=
orbell, and
> scratch-pad registers as well as use them in such a way as they can b=
e turned
> into a viable communication channel to the remote system.  ntb_hw.[ch=
]
> determines the usage model (NTB to NTB or NTB to Root Port) and abstr=
acts away
> the underlying hardware to provide access and a common interface to t=
he doorbell
> registers, scratch pads, and memory windows.  These hardware interfac=
es are
> exported so that other, non-mainlined kernel drivers can access these=
=2E
> ntb_transport.[ch] also uses the exported interfaces in ntb_hw.[ch] t=
o setup a
> communication channel(s) and provide a reliable way of transferring d=
ata from
> one side to the other, which it then exports so that "client" drivers=
 can access
> them.  These client drivers are used to provide a standard kernel int=
erface
> (i.e., Ethernet device) to NTB, such that Linux can transfer data fro=
m one
> system to the other in a standard way.
>=20
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> Reviewed-by: Nicholas Bellinger <nab@linux-iscsi.org>

Sorry for the very long delay, I've now applied these two patches,
thanks for the cleanups and changes from the original versions.

But, I now get the following build warning, so can you send a follow-on
patch that fixes it up before you start getting angry emails from the
0-day build bot?

drivers/ntb/ntb_transport.c: In function =E2=80=98ntb_transport_rx=E2=80=
=99:
drivers/ntb/ntb_transport.c:895:7: warning: =E2=80=98offset=E2=80=99 ma=
y be used uninitialized in this function [-Wuninitialized]
drivers/ntb/ntb_transport.c:891:8: note: =E2=80=98offset=E2=80=99 was d=
eclared here


thanks,

greg k-h

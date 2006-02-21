From: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
Subject: Re: From: Carlos   Mart??n <carlos@cmartin.tk>
Date: Tue, 21 Feb 2006 22:03:58 +0100
Message-ID: <200602212203.58216.carlos@cmartin.tk>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <200602212124.23572.carlos@cmartin.tk> <20060221203211.GA29627@infradead.org>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060221203211.GA29627@infradead.org>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Tuesday 21 February 2006 21:32, Christoph Hellwig wrote:
> On Tue, Feb 21, 2006 at 09:24:23PM +0100, Carlos Mart?n wrote:
> > Wouldn't this lead to duplicated function definitions at link time if b=
oth=20
are=20
> > compiled-in? From your module split above I understood you wanted=20
acx-common=20
> > to be another module, but here I see it goes into the modules.
> >=20
>=20
> No.  The above makefile fragment builds three modules: acx-common.o,
> acx-pci.o and acx-usb.o as mentioned above.  The magic here is that with
> that makefile fragment is that the kbuild systems builds acx-common.o if
> either CONFIG_ACX_PCI or CONFIG_ACX_USB is set, and even makes sure to
> do the right thing if either is builtin.  There is not code duplication
> at all.

Then all is good.

>=20
> > > ---- snip ----
> > >=20
> > >  - kill the IS_PCI/IS_USB macros and add a acx_operations structure t=
hat
> > >    handles the different hardware without branches all over and allows
> > >    the hw-specific code to be in separate modules.
> >=20
> > There aren't that many IS_{PCI,USB} uses and most if not all are justif=
ied=20
> > (extra step for one case). It might be a good idea to do that for the=20
> > IS_ACX{100,111} macros instead of calling the generic function which th=
en=20
> > calls the chip-specific one.
>=20
> The important bit is that you need the pointers with the above module
> spit, because you can't call usb- or pci-specific routines from=20
> acx-common.ko=20

Yes, I realise that (unless you export them, but I don't think we want that=
).=20
I've started this, but I think it'll probably be next week before I have ti=
me=20
to really work on it.

This approach is probably better even if the driver is unified. Pointer=20
dereferences are cheaper than branches/jumping, aren't they?

   cmn
=2D-=20
Carlos Mart=EDn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642

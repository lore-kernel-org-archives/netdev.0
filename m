From: Casey Leedom <leedom@chelsio.com>
Subject: RE: chelsio: Use a more common const struct pci_device_id foo[]
 style
Date: Mon, 16 Feb 2015 19:07:44 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADB9E035@nice.asicdesigners.com>
References: <1423879550.2795.12.camel@perches.com>
	 <4985EFDD773FCB459EF7915D2A3621ADB9E00A@nice.asicdesigners.com>,<1424110879.8287.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hariprasad S <hariprasad@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	David Miller <davem@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424110879.8287.3.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  I understand that OS-independence issues aren't something which are n=
ormally accommodated, but as long as definitions don't introduce unnece=
ssary "foreign intrusion" I would hope that it would be okay.  As I not=
ed, our t4_regs.h file is also OS-independent and used by six other OS =
device drivers.  Putting Linux definitions into t4_pci_id_tbl.h would b=
e somewhat akin to injecting Linux dependencies into t4_regs.h.

  But, if the change must be made, then we'll just maintain a translati=
on between our Common Code and the kernel.org code.  If that's the case=
, probably the best documentation for the proposed CH_PCI_ID_TABLE_ENTR=
Y_DATA might be something like:

 * CH_PCI_ID_TABLE_ENTRY_DATA
 *   -- Used for the individual PCI Device ID entries for the PCI_VDEVI=
CE() "dev"
 *   -- parameter.

  So it sounds like Chelsio would be required to make this change then?=
  I'm still unclear on the likes of responsibility/authority here.  We'=
re being told that we must do this but we have to be the ones requestin=
g it?  Sorry for my confusion.  (Which is doubly apparent since I came =
into work this morning only to realize that it's a company holiday.  Co=
lor me a moron today.)

Casey

________________________________________
=46rom: Joe Perches [joe@perches.com]
Sent: Monday, February 16, 2015 10:21 AM
To: Casey Leedom
Cc: Hariprasad S; James E.J. Bottomley; netdev@vger.kernel.org; linux-k=
ernel@vger.kernel.org; linux-scsi; David Miller
Subject: Re: chelsio: Use a more common const struct pci_device_id foo[=
] style

On Mon, 2015-02-16 at 18:05 +0000, Casey Leedom wrote:
>   I can't quite tell if this is a patch request being sent to
> netdev/David Miller or if it's a suggestion sent to Chelsio that you'=
d
> like Chelsio to adopt.  I ~think~ it's the latter because the subject
> doesn't include the standard formatting for a patch request but I'm
> not 100% familiar with the netdev/kernel.org conventions for this.  M=
y
> apologies if I'm misinterpreting your message.

Hi Casey.

Nah, that's not it.

I just forgot/neglected to prefix [PATCH] on the email when I
sent it.

The patch touches drivers/net/ethernet and drivers/scsi which
generally means that it's better for the company maintainers
to apply rather than coordinating between David and James,
the linux networking and scsi maintainers.  Those guys for
most part don't like touching each others code areas.

> 1.  The use of "const" certainly seems like a win.

I think so.

My goal here was to make obvious the use of
"const struct pci_device_id" which in the original is very
obfuscated/unclear.

>  2. Thanks for catching the redundant use of CH_PCI_DEVICE_ID_TABLE_D=
EFINE_BEGIN to guard
>     the actual contents of t4_pci_id_tbl.h.  That's already being han=
dled via the check for
>     __T4_PCI_ID_TBL_H__ =97 no idea why I put that in there ...

That didn't matter much to me.

>  3. The use of the CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN and
>     CH_PCI_DEVICE_ID_TABLE_DEFINE_END are used to make the t4_pci_id_=
tbl.h
>     accommodate different driver needs.  The header file is only conc=
erned with providing
>     a common enumeration of existing PCI Device Identifiers associate=
d with adapters.
>     The files including the header are only concerned with providing =
the necessary context
>     for the header file.  The header file ai an OS-independent header=
 file which is
>     shared across six existing OS driver implementations; similar to =
our OS-independent
>     register definitions file.

I think that OS independent bit is not useful here.

>  4. The CH_PCI_ID_TABLE_ENTRY() macro is similarly used to strictly p=
artition
>     the roles of t4_pci_id_tbl.h and the files which include it.  t4_=
pci_id_tbl.h is
>     exactly what it's name implies: solely an enumeration of assigned=
 hardware
>     adapter PCI Device Identifiers.

Which is how it's used both before and after this change.

>  5. Because of the above change in the original abstraction layering,=
 a new macro
>     CH_PCI_ID_TABLE_ENTRY_DATA is introduced in this patch which pass=
es in
>     a desired value for the "dev" parameter of the PCI_VDEVICE() macr=
o.  But the
>     documentation for this new macro in t4_pci_id_tbl.h is incorrectl=
y given the
>     documentation of the original CH_PCI_ID_TABLE_ENTRY() macro which
>     was originally supplied by the file including t4_pci_id_tbl.h.  T=
his leaves its
>     usage confusing for anyone reading the header file.

Do you have any clarifying text to suggest?

cheers, Joe

> In conclusion:
>
>  A. I like the use of "const" in the table.
>
>  B. I like removing the redundant content inclusion check of
>     CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN.
>
>  C. I'm uncomfortable with all the other changes.

> Casey
>
> ________________________________________
> From: Joe Perches [joe@perches.com]
> Sent: Friday, February 13, 2015 6:05 PM
> To: Hariprasad S; Casey Leedom; James E.J. Bottomley
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linux-scsi
> Subject: chelsio: Use a more common const struct pci_device_id foo[] =
style
>
> Chelsio code shares a pci_device_table from an #include file.
> Make the include guard simpler and make the arrays const.
>
> Reduces data by moving tables to text.
>
> Removed unnecessary macros:
> o CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
> o CH_PCI_DEVICE_ID_TABLE_DEFINE_END
> o CH_PCI_ID_TABLE_ENTRY (moved to the .h file)
> Added new macro define:
> o CH_PCI_ID_TABLE_ENTRY_DATA
>
>   text     data     bss     dec     hex filename
>   50550     923     172   51645    c9bd drivers/net/ethernet/chelsio/=
cxgb4/cxgb4_main.o.new
>   46935    4531     172   51638    c9b6 drivers/net/ethernet/chelsio/=
cxgb4/cxgb4_main.o.old
>   27864     355       8   28227    6e43 drivers/net/ethernet/chelsio/=
cxgb4vf/cxgb4vf_main.o.new
>   26072    2203       8   28283    6e7b drivers/net/ethernet/chelsio/=
cxgb4vf/cxgb4vf_main.o.old
>    9734     450      24   10208    27e0 drivers/scsi/csiostor/csio_in=
it.o.new
>    7942    2242      24   10208    27e0 drivers/scsi/csiostor/csio_in=
it.o.old

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCHES] Bringing Orinoco to 0.15
Date: Fri, 07 Apr 2006 04:07:31 -0400
Message-ID: <1144397251.14299.6.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Andrew Morton <akpm-LL/9OlyS9hIAvxtiuMwx3w@public.gmane.org>, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Hello!

I'm about to submit series of 21 patches for Orinoco drivers.  Those
patches have been in Orinoco CVS for months, and there have been no bug
reports.  I believe it's about time that I submit the patches to the
kernel.

I know, I've missed the boat for 2.6.17 (sorry for that, I was really
overworked), but I hope it's better to submit the patches as early as
possible so that they get some public exposure before ending up in the
kernel.

The changes are minimal, despite the size of the patches.  The intention
was to make as much cleanup as possible and call it 0.15, and then start
doing real changes.

The patches are available at http://red-bean.com/proski/orinoco/
This includes the cumulative patch and a zip archive with all patches.

Andrew, maybe you you include the patches into the "mm" kernel?

Here's a brief overview of the changes:

1) Remove old cruft, such as obsolete PCMCIA code, obsolete comments,
obsolete debug code.

2) Fix misleading comments.  For instance, Symbol Spectrum24 LA4137 was
called Symbol Spectrum24 LA4100.

3) Fixes for minor annoyances, such as a kernel warning emitted every
time when iwconfig requests stats on recent Symbol firmware.

4) Optimization for Tx exception handling.  No need to read the complete
Tx descriptor if just a few fields are needed.

5) Serious rework of the Tx code.  The low level function for copying
data to the card has been changed to accept odd number of bytes, which
allows to remove all padding code used in the kernel.  Not a single
unwanted byte would leak to the air.  Also, error handling has been
redone, transmit errors are counted in one place, and orinoco_xmit()
returns what the network layer expects it to, rather than -errno.  802.3
encapsulation has been slightly simplified.

6) The driver will reset the card in case of some bad Tx errors.

7) The driver will print the firmware version before trying to allocate
the transmission buffer, so that users can report the firmware version
in case of errors.

8) "Pseudo-PCI" drivers (i.e. drivers for cards in primitive
PCI-to-PCMCIA adaptors) support suspend and resume now.

9) PCI suspend frees the IRQ and disables the device.

10) All I/O is done using the iomem API.

11) The code common between PCI and pseudo-PCI drivers has been put to
orinoco_pci.h.  The drivers have been changed to minimize differences
between them.  Sorry, it's a big patch, but that's how it was made, and
splitting it would be rewriting history.  I did split what I could
(comment changes).

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642

From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: Linux 2.6.7
Date: Wed, 16 Jun 2004 13:18:51 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040616121850.GO12308@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.58.0406152253390.6392@ppc970.osdl.org> <20040616111329.GA1571@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266259AbUFPMSx@vger.kernel.org>
To: Tomas Szepe <szepe@pinerecords.com>
Content-Disposition: inline
In-Reply-To: <20040616111329.GA1571@louise.pinerecords.com>
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 01:13:29PM +0200, Tomas Szepe wrote:
> On Jun-15 2004, Tue, 22:56 -0700
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
> > Summary of changes from v2.6.7-rc3 to v2.6.7
> [snip]
> 
> 2.6.7's airo.ko (unlike 2.6.6's) won't allow the user to set
> ESSID via "echo myessid >/proc/driver/aironet/ethX/SSID".
> 
> Changes like this shouldn't probably be made in the middle
> of a stable series.

Changes like this are called bugs.  The thing is, original variant of
function (actually, both read and write) was also buggy and trivially
exploitable, so fixing it was needed.  Fscking it up was not, obviously.

Fix follows; see if it works for you.

--- RC7/drivers/net/wireless/airo.c	Mon Jun  7 19:21:27 2004
+++ RC7-current/drivers/net/wireless/airo.c	Wed Jun 16 08:11:50 2004
@@ -4527,6 +4527,8 @@
 		len = priv->maxwritelen - pos;
 	if (copy_from_user(priv->wbuffer + pos, buffer, len))
 		return -EFAULT;
+	if (pos + len > priv->writelen)
+		priv->writelen = pos + len;
 	*offset = pos + len;
 	return len;
 }

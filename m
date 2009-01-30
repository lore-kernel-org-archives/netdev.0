From: David Miller <davem@davemloft.net>
Subject: Re: tun new missing ioctl32
Date: Thu, 29 Jan 2009 16:53:55 -0800 (PST)
Message-ID: <20090129.165355.220606336.davem@davemloft.net>
References: <49823F39.8080204@msgid.tls.msk.ru>
	<20090129.160600.73249925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44700
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751773AbZA3Ax5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:53:57 -0500
In-Reply-To: <20090129.160600.73249925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 29 Jan 2009 16:06:00 -0800 (PST)

> From: Michael Tokarev <mjt@tls.msk.ru>
> Date: Fri, 30 Jan 2009 02:43:53 +0300
> 
> > Just saw in dmesg:
> > 
> > ioctl32(kvm:4408): Unknown cmd fd(9) cmd(800454cf){t:'T';sz:4} arg(ffc668e4) on /dev/net/tun
> > 
> > I guess it's the recent stuff, TUNSETOFFLOAD perhaps, which is
> > missing compat_ioctl entry...  Who knows this area, care to fix
> > it please? :)
> 
> I'll take a look at this, thanks for the report.

This should fix it:

tun: Add some missing TUN compat ioctl translations.

Based upon a report from Michael Tokarev <mjt@tls.msk.ru>:

	Just saw in dmesg:

	ioctl32(kvm:4408): Unknown cmd fd(9) cmd(800454cf){t:'T';sz:4} arg(ffc668e4) on /dev/net/tun

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 fs/compat_ioctl.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 5235c67..c8f8d59 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -538,6 +538,7 @@ static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
 		 * cannot be fixed without breaking all existing apps.
 		 */
 		case TUNSETIFF:
+		case TUNGETIFF:
 		case SIOCGIFFLAGS:
 		case SIOCGIFMETRIC:
 		case SIOCGIFMTU:
@@ -1982,6 +1983,11 @@ COMPATIBLE_IOCTL(TUNSETNOCSUM)
 COMPATIBLE_IOCTL(TUNSETDEBUG)
 COMPATIBLE_IOCTL(TUNSETPERSIST)
 COMPATIBLE_IOCTL(TUNSETOWNER)
+COMPATIBLE_IOCTL(TUNSETLINK)
+COMPATIBLE_IOCTL(TUNSETGROUP)
+COMPATIBLE_IOCTL(TUNGETFEATURES)
+COMPATIBLE_IOCTL(TUNSETOFFLOAD)
+COMPATIBLE_IOCTL(TUNSETTXFILTER)
 /* Big V */
 COMPATIBLE_IOCTL(VT_SETMODE)
 COMPATIBLE_IOCTL(VT_GETMODE)
@@ -2573,6 +2579,7 @@ HANDLE_IOCTL(SIOCGIFPFLAGS, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFTXQLEN, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFTXQLEN, dev_ifsioc)
 HANDLE_IOCTL(TUNSETIFF, dev_ifsioc)
+HANDLE_IOCTL(TUNGETIFF, dev_ifsioc)
 HANDLE_IOCTL(SIOCETHTOOL, ethtool_ioctl)
 HANDLE_IOCTL(SIOCBONDENSLAVE, bond_ioctl)
 HANDLE_IOCTL(SIOCBONDRELEASE, bond_ioctl)
-- 
1.6.1.2.253.ga34a


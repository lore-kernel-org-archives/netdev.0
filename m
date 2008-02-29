From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Fri, 29 Feb 2008 14:10:58 -0500
Message-ID: <20080229191058.GD3234@tuxdriver.com>
References: <20080228014125.GI3078@tuxdriver.com> <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com> <20080228.133008.228590007.davem@davemloft.net> <200802291316.59738.mb@bu3sch.de> <20080229162629.GB3234@tuxdriver.com> <1204302853.3938.40.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1204302853.3938.40.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 29, 2008 at 05:34:13PM +0100, Johannes Berg wrote:
> 
> On Fri, 2008-02-29 at 11:26 -0500, John W. Linville wrote:
> > On Fri, Feb 29, 2008 at 01:16:59PM +0100, Michael Buesch wrote:
> > 
> > > I'm wondering if we can't simply pass a commandline parameter to file2alias
> > > that tells it whether we are crosscompiling. It should simply omit the sanity check
> > 
> > Sounds reasonable to me.
> 
> In fact, file2alias shouldn't need a command line argument ...
> 
> > > in that case. Is there any easy and reliable way to find out whether we
> > > are crosscompiling from a makefile (I don't know the makefile core that much)?
> > 
> > Non-empty CROSS_COMPILE definition?
> 
> ... it can just check whether CROSS_COMPILE is set in its environment.
> No?

Not a bad idea...something like this?

---

modpost: avoid user/kernel struct size compat check if cross-compiling

Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 scripts/mod/file2alias.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/scripts/mod/file2alias.c b/scripts/mod/file2alias.c
index 9ddf944..040721e 100644
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@ -10,6 +10,7 @@
  * of the GNU General Public License, incorporated herein by reference.
  */
 
+#include <stdlib.h>
 #include "modpost.h"
 
 /* We use the ELF typedefs for kernel_ulong_t but bite the bullet and
@@ -63,6 +64,12 @@ static void device_id_check(const char *modname, const char *device_id,
 {
 	int i;
 
+	if (getenv("CROSS_COMPILE")) {
+		warn("%s: cross-compile can not verify userspace/kernel "
+		     "structure size compatibility.\n", modname);
+		return;
+	}
+
 	if (size % id_size || size < id_size) {
 		fatal("%s: sizeof(struct %s_device_id)=%lu is not a modulo "
 		      "of the size of section __mod_%s_device_table=%lu.\n"
-- 
1.5.3.3

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

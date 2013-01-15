From: Cong Wang <amwang@redhat.com>
Subject: Re: the patch "bridge: export multicast database via netlink" broke
 kernel 3.8 uapi (was: Re: [libvirt] if_bridge.h: include in6.h for struct
 in6_addr use)
Date: Tue, 15 Jan 2013 18:11:28 +0800
Message-ID: <1358244688.4264.7.camel@cr0>
References: <50F2FF1B.3020708@mageia.org> <50F313A5.3020707@mageia.org>
	 <50F49B7E.50906@redhat.com> <50F52956.50201@mageia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Blake <eblake@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch
To: Thomas Backlund <tmb@mageia.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50F52956.50201@mageia.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-15 at 12:03 +0200, Thomas Backlund wrote:
> Eric Blake skrev 15.1.2013 01:57:
> > On 01/13/2013 01:05 PM, Thomas Backlund wrote:
> >> Thomas Backlund skrev 13.1.2013 20:38:
> >>> patch both inline and attached as thunderbird tends to mess up ...
> >>
> >>> -----
> >>>
> >>> if_bridge.h uses struct in6_addr ip6; but does not include the in6.h
> >>> header.
> >>>
> >>> Found by trying to build libvirt and connman against 3.8-rc3 headers.
> >>>
> >>
> >> Ok,
> >> ignore this patch, it's not the correct fix as it introduces
> >> redefinitions...
> >>
> >> Btw, the error that I hit that made me suggest this fix was libvirt
> >> config check bailing out:
> >>
> >> config.log:/usr/include/linux/if_bridge.h:173:20: error: field 'ip6' has
> >> incomplete type
> >
> > Hmm, just now noticing this thread, after independently hitting and and
> > having to work around the same problem in libvirt:
> > https://www.redhat.com/archives/libvir-list/2013-January/msg00930.html
> > https://bugzilla.redhat.com/show_bug.cgi?id=895141
> 
> 
> Yep,
> 
> and the commit breaking uapi headers is by using "struct in6_addr ip6" is:
> 
> 
>  From ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 Mon Sep 17 00:00:00 2001
> From: Cong Wang <amwang@redhat.com>
> Date: Fri, 7 Dec 2012 00:04:48 +0000
> Subject: [PATCH] bridge: export multicast database via netlink

Does the following patch help?

$ git diff include/uapi/linux/if_bridge.h
diff --git a/include/uapi/linux/if_bridge.h
b/include/uapi/linux/if_bridge.h
index 5db2975..653db23 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -14,6 +14,7 @@
 #define _UAPI_LINUX_IF_BRIDGE_H
 
 #include <linux/types.h>
+#include <linux/in6.h>
 
 #define SYSFS_BRIDGE_ATTR      "bridge"
 #define SYSFS_BRIDGE_FDB       "brforward"

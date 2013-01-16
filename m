From: Cong Wang <amwang@redhat.com>
Subject: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Wed, 16 Jan 2013 14:06:06 +0800
Message-ID: <1358316366.14898.8.camel@cr0>
References: <50F2FF1B.3020708@mageia.org> <50F313A5.3020707@mageia.org>
	  <50F49B7E.50906@redhat.com> <50F52956.50201@mageia.org>
	 <1358244688.4264.7.camel@cr0> <50F53596.4070200@mageia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Blake <eblake@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, libvirt-list@redhat.com, tgraf@suug.ch,
        David
 Miller <davem@davemloft.net>, libc-alpha@sourceware.org,
        schwab@suse.de, carlos@systemhalted.org
To: Thomas Backlund <tmb@mageia.org>
Return-path: <libc-alpha-return-36252-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <50F53596.4070200@mageia.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

(Cc'ing some glibc developers...)

Hello,

In glibc source file inet/netinet/in.h and kernel source file
include/uapi/linux/in6.h, both define struct in6_addr, and both are
visible to user applications. Thomas reported a conflict below.

So, how can we handle this? /me is wondering why we didn't see this
before.

Thanks.

On Tue, 2013-01-15 at 12:55 +0200, Thomas Backlund wrote:
> Cong Wang skrev 15.1.2013 12:11:
> >
> > Does the following patch help?
> >
> > $ git diff include/uapi/linux/if_bridge.h
> > diff --git a/include/uapi/linux/if_bridge.h
> > b/include/uapi/linux/if_bridge.h
> > index 5db2975..653db23 100644
> > --- a/include/uapi/linux/if_bridge.h
> > +++ b/include/uapi/linux/if_bridge.h
> > @@ -14,6 +14,7 @@
> >   #define _UAPI_LINUX_IF_BRIDGE_H
> >
> >   #include <linux/types.h>
> > +#include <linux/in6.h>
> >
> >   #define SYSFS_BRIDGE_ATTR      "bridge"
> >   #define SYSFS_BRIDGE_FDB       "brforward"
> >
> 
> Well, I suggested the same fix in the beginning of the thread
> on netdev and lkml: "if_bridge.h: include in6.h for struct in6_addr use"
> 
> as it seemed to fix the libvirt case
> 
> but then asked it to be ignored after I tried to build connman,
> and hit this conflict with glibc-2.17:
> 
> In file included from /usr/include/arpa/inet.h:22:0,
>                   from ./include/connman/inet.h:25,
>                   from src/connman.h:128,
>                   from src/tethering.c:40:
> /usr/include/netinet/in.h:35:5: error: expected identifier before 
> numeric constant
> /usr/include/netinet/in.h:197:8: error: redefinition of 'struct in6_addr'
> In file included from /usr/include/linux/if_bridge.h:17:0,
>                   from src/tethering.c:38:
> /usr/include/linux/in6.h:30:8: note: originally defined here
> In file included from /usr/include/arpa/inet.h:22:0,
>                   from ./include/connman/inet.h:25,
>                   from src/connman.h:128,
>                   from src/tethering.c:40:
> /usr/include/netinet/in.h:238:8: error: redefinition of 'struct 
> sockaddr_in6'
> In file included from /usr/include/linux/if_bridge.h:17:0,
>                   from src/tethering.c:38:
> /usr/include/linux/in6.h:46:8: note: originally defined here
> In file included from /usr/include/arpa/inet.h:22:0,
>                   from ./include/connman/inet.h:25,
>                   from src/connman.h:128,
>                   from src/tethering.c:40:
> /usr/include/netinet/in.h:274:8: error: redefinition of 'struct ipv6_mreq'
> In file included from /usr/include/linux/if_bridge.h:17:0,
>                   from src/tethering.c:38:
> /usr/include/linux/in6.h:54:8: note: originally defined here
> make[1]: *** [src/src_connmand-tethering.o] Error 1
> 
> 
> So I'm not sure it's the right one...
> 

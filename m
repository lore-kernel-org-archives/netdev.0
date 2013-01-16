From: Cong Wang <amwang@redhat.com>
Subject: Re: the patch "bridge: export multicast database via netlink" broke
 kernel 3.8 uapi
Date: Wed, 16 Jan 2013 13:51:55 +0800
Message-ID: <1358315515.14898.0.camel@cr0>
References: <50F2FF1B.3020708@mageia.org> <50F313A5.3020707@mageia.org>
	  <50F49B7E.50906@redhat.com> <50F52956.50201@mageia.org>
	 <1358244688.4264.7.camel@cr0> <50F53596.4070200@mageia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Blake <eblake@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch
To: Thomas Backlund <tmb@mageia.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831Ab3APFwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 00:52:12 -0500
In-Reply-To: <50F53596.4070200@mageia.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 12:55 +0200, Thomas Backlund wrote:
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

% rpm -q --whatprovides /usr/include/netinet/in.h 
glibc-headers-2.14.90-24.fc16.9.x86_64

Seems we have conflicts with glibc headers...

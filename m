From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Re: Kernel 2.6.37-git10 build failure: cassini.c
Date: Fri, 14 Jan 2011 18:02:30 +0200
Message-ID: <AANLkTikrCeTNWzGxCx5ZvBbYM09No-f013i5J=nfW3p1@mail.gmail.com>
References: <AANLkTin61iqrD0Jbax+cvQ1wxD8b=c4KJv7pBSvU7kbv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>,
	Christoph Egger <siccegge@cs.fau.de>,
	Jiri Pirko <jpirko@redhat.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57888 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728Ab1ANQCc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 11:02:32 -0500
In-Reply-To: <AANLkTin61iqrD0Jbax+cvQ1wxD8b=c4KJv7pBSvU7kbv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 10:09 AM, Anca Emanuel <anca.emanuel@gmail.com>=
 wrote:
> drivers/net/cassini.c: In function =91cas_get_vpd_info=92:
> drivers/net/cassini.c:3358: error: implicit declaration of function
> =91of_get_property=92
> drivers/net/cassini.c:3358: warning: assignment makes pointer from
> integer without a cast
> drivers/net/cassini.c: In function =91cas_init_one=92:
> drivers/net/cassini.c:5035: error: implicit declaration of function
> =91pci_device_to_OF_node=92
> drivers/net/cassini.c:5035: warning: assignment makes pointer from
> integer without a cast
> make[3]: *** [drivers/net/cassini.o] Error 1
> make[2]: *** [drivers/net] Error 2
>
>
> The first part can be solved with:
>
> diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
> index 7206ab2..fe3795e 100644
> --- a/drivers/net/cassini.c
> +++ b/drivers/net/cassini.c
> @@ -94,6 +94,7 @@
> =A0#include <linux/tcp.h>
> =A0#include <linux/mutex.h>
> =A0#include <linux/firmware.h>
> +#include <linux/of.h>
>
> =A0#include <net/checksum.h>
>

The second part it's a little bit harder, because:
http://lxr.linux.no/linux+v2.6.37/+search=3Dpci_device_to_OF_node
there is no generic function, only microblaze, powerpc and sparc are
there as users.

Still not solved in git11.
I'm testing this from x86, Ubuntu 10.10 standard config.

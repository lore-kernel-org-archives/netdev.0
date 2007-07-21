From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH][12/37] Clean up duplicate includes in drivers/net/
Date: Sat, 21 Jul 2007 18:48:07 +0200
Message-ID: <9a8748490707210948k468f8f32k718d84279aa56ce9@mail.gmail.com>
References: <200707211702.46375.jesper.juhl@gmail.com>
	<46A236FC.2080300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: info@netxen.com, Luke Yang <luke.yang@analog.com>,
	Judy Fischbach <jfisch@cs.pdx.edu>, Patrick McHardy <kaber@coreworks.de>,
	bonding-devel@lists.sourceforge.net,
	Bryan Wu <bryan.wu@analog.com>, kong.lai@tundra.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	James Morris <jmorris@namei.org>, linuxppc-embedded@ozlabs.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Alex V Lasso <a_villacis@palosanto.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Amit S Kale <amitkale@netxen.com>, Jay Cliburn <jcliburn@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>, Daniel Drake <dsd@gentoo.org>,
	Brian Pugh <bpugh@cs.pdx.edu>, viro@ftp.linux.org.uk,
	alexandre.bounine@tundra.com,
	Pantelis Antoniou <panto@intracom.gr>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.or
To: "Chris Snook" <csnook@redhat.com>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <46A236FC.2080300@redhat.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On 21/07/07, Chris Snook <csnook@redhat.com> wrote:
> Jesper Juhl wrote:
> > Hi,
> >
> > This patch cleans up duplicate includes in
> >        drivers/net/
> >
> >
> > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> > ---
> >
> > diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
> > index fd1e156..4a18b88 100644
> > --- a/drivers/net/atl1/atl1_main.c
> > +++ b/drivers/net/atl1/atl1_main.c
> > @@ -75,7 +75,6 @@
> >  #include <linux/compiler.h>
> >  #include <linux/delay.h>
> >  #include <linux/mii.h>
> > -#include <linux/interrupt.h>
> >  #include <net/checksum.h>
> >
> >  #include <asm/atomic.h>
>
> Define "duplicate".  I ask because this patch just got posted a few days ago:
>

duplicate == present more than once in the same source file.
Did you try looking at the includes in the source file the patch modifies?


> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>   drivers/net/atl1/atl1_main.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
> index 4a18b88..fd1e156 100644
> --- a/drivers/net/atl1/atl1_main.c
> +++ b/drivers/net/atl1/atl1_main.c
> @@ -75,6 +75,7 @@
>   #include <linux/compiler.h>
>   #include <linux/delay.h>
>   #include <linux/mii.h>
> +#include <linux/interrupt.h>
>   #include <net/checksum.h>
>
>   #include <asm/atomic.h>
>
> I've always been under the impression that one should include all the files
> whose contents you use directly, because other includes that happen to include
> them might no longer need to in the future and cease including them.

I agree completely. But that's completely beside the point here.

Before Al's patch, drivers/net/atl1/atl1_main.c already contained
"#include <linux/interrupt.h>".

> You can
> fight it out with Al if you feel like it.  I'm keeping the rest of the CC list
> because the other maintainers might have similar feelings about the
> appropriateness of these includes in their drivers.
>

Take a look at the file. These are the includes at the top of
drivers/net/atl1/atl1_main.c :

...
#include <linux/types.h>
#include <linux/netdevice.h>
#include <linux/pci.h>
#include <linux/spinlock.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/skbuff.h>
#include <linux/etherdevice.h>
#include <linux/if_vlan.h>
#include <linux/irqreturn.h>
#include <linux/workqueue.h>
#include <linux/timer.h>
#include <linux/jiffies.h>
#include <linux/hardirq.h>
#include <linux/interrupt.h>          <--- Here we have linux/interrupt.h
#include <linux/irqflags.h>
#include <linux/dma-mapping.h>
#include <linux/net.h>
#include <linux/pm.h>
#include <linux/in.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/compiler.h>
#include <linux/delay.h>
#include <linux/mii.h>
#include <linux/interrupt.h>          <--- And here we include it again.
#include <net/checksum.h>

#include <asm/atomic.h>
#include <asm/byteorder.h>

#include "atl1.h"
...

Now please tell me why it makes sense to include the same header twice
and why my patch that removes the duplicate does not make sense.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

From: "Randy Dunlap" <rdunlap@xenotime.net>
Subject: Re: [RFC PATCH 1/4] PHY Abstraction Layer III (now with more
	splitiness)
Date: Wed, 27 Jul 2005 11:08:28 -0700
Message-ID: <1122487708.20267@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>,
	Francois Romieu <romieu@fr.zoreil.com>, Netdev <netdev@vger.kernel.org>,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


> On Jul 25, 2005, at 16:06, Francois Romieu wrote:
> 
> 
> >> +int mdiobus_register(struct mii_bus *bus)
> >> +{
> >> +    int i;
> >> +    int err = 0;
> >> +
> >> +    spin_lock_init(&bus->mdio_lock);
> >> +
> >> +    if (NULL == bus || NULL == bus->name ||
> >> +            NULL == bus->read ||
> >> +            NULL == bus->write)
> >>
> >
> > Be spartan:
> >     if (!bus || !bus->name || !bus->read || !bus->write)
> 
> 
> I think we have to agree to disagree here.  I could be convinced, but  
> I'm partial to using NULL explicitly.

But there are 2 issues here (at least).  One is to use NULL or
not.  The other is using (constant == var) or (var == constant).

It's not described in CodingStlye afaik, but most recent email
on the subject strongly prefers (var == constant) [in my
unscientific survey -- of bits in my head].

So using the suggested style will fix both of these.  :)

> >> +    /* Otherwise, we allocate the device, and initialize the
> >> +     * default values */
> >> +    dev = kmalloc(sizeof(*dev), GFP_KERNEL);
> >> +
> >> +    if (NULL == dev) {
> >> +        errno = -ENOMEM;
> >> +        return NULL;
> >> +    }
> >> +
> >> +    memset(dev, 0, sizeof(*dev));
> >>
> >
> > The kernel provides kcalloc.
> 
> 
> I went looking for it, and found it in fs/cifs/misc.c.  I'm hesitant  
> to link to a function defined in the filesystem code just to save 1  
> line of code

It's more global than that.

~Randy

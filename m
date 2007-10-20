From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
	pci: Export the pci_restore_msi_state() function
Date: Sat, 20 Oct 2007 15:50:17 -0700
Message-ID: <1192920617.5369.27.camel@dell>
References: <20071020000421.GO29903@austin.ibm.com>
	<20071019.172706.57467960.davem@davemloft.net>
	<20071020004610.GR29903@austin.ibm.com>
	<20071019.175308.54212640.davem@davemloft.net>
	<1192862606.7688.4.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, mcarlson@broadcom.com,
	linuxppc-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz,
	David Miller <davem@davemloft.net>
To: michael@ellerman.id.au
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1192862606.7688.4.camel@concordia>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-10-20 at 16:43 +1000, Michael Ellerman wrote:
> On Fri, 2007-10-19 at 17:53 -0700, David Miller wrote:
> > I don't see this, in all cases write_msi_msg() will transfer
> > the given "*msg" to entry->msg by this assignment in
> > drivers/pci/msi.c:
> > 
> > void write_msi_msg(unsigned int irq, struct msi_msg *msg)
> > {
> >  ...
> > 	entry->msg = *msg;
> > }
> > 
> > So as long as write_msi_msg() is invoked, it will be saved
> > properly.
> > 
> > Platforms need not do this explicitly.
> 
> I'm short on context here, and it's Saturday, so excuse me if I'm
> missing the point somewhere.
> 
> On pseries machines we don't call write_msi_msg(), because we don't
> control the contents of the message, firmware does. So entry->msg will
> be bogus.
> 
> That's a pity, but AFAIK it shouldn't be a problem because we don't
> enable CONFIG_PM on those machines anyway. If we ever want to we'll need
> to sort out with firmware how that will work WRT restoring MSI state.
> 

The PCI error recovery that Linas is working on requires the MSI state
to be restored after we do PCI reset to recover from PCI errors.

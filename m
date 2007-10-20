From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
	pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 17:53:08 -0700 (PDT)
Message-ID: <20071019.175308.54212640.davem@davemloft.net>
References: <20071020000421.GO29903@austin.ibm.com>
	<20071019.172706.57467960.davem@davemloft.net>
	<20071020004610.GR29903@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, linuxppc-dev@ozlabs.org,
	mchan@broadcom.com, linux-pci@atrey.karlin.mff.cuni.cz
To: linas@austin.ibm.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071020004610.GR29903@austin.ibm.com>
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

From: linas@austin.ibm.com (Linas Vepstas)
Date: Fri, 19 Oct 2007 19:46:10 -0500

> FWIW, it looks like not all that many arches do this; the output
> for grep -r address_hi * is pretty thin. Then, looking at
> i386/kernel/io_apic.c as an example, one can see that the 
> msi state save happens "by accident" if CONFIG_SMP is enabled;
> and so its surely broekn on uniprocesor machines.

I don't see this, in all cases write_msi_msg() will transfer
the given "*msg" to entry->msg by this assignment in
drivers/pci/msi.c:

void write_msi_msg(unsigned int irq, struct msi_msg *msg)
{
 ...
	entry->msg = *msg;
}

So as long as write_msi_msg() is invoked, it will be saved
properly.

Platforms need not do this explicitly.

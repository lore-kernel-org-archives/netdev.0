From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Tue, 12 Feb 2008 10:04:09 -0800
Message-ID: <1202839449.11188.35.camel@nimitz.home.sr71.net>
References: <200802111724.12416.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Themann, Jan-Bernd" <themann@de.ibm.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <RAISCH@de.ibm.com>, Greg KH <greg@kroah.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200802111724.12416.ossthema@de.ibm.com>
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

On Mon, 2008-02-11 at 17:24 +0100, Jan-Bernd Themann wrote:
> Drivers like eHEA need memory notifiers in order to 
> update their internal DMA memory map when memory is added
> to or removed from the system.
> 
> Patch for eHEA memory hotplug support that uses these functions:
> http://www.spinics.net/lists/netdev/msg54484.html

This driver is broken pretty horribly.  It won't even compile for a
plain ppc64 kernel:

http://sr71.net/~dave/linux/ehea-is-broken.config

I know it's used for very specific hardware, but this is the symptom of
it not using the proper abstracted interfaces to the VM.

In file included from /home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_main.c:42:
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.h:44:14: warning: "SECTION_SIZE_BITS" is not defined
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.h:45:2: error: #error eHEA module cannot work if kernel sectionsize < ehea sectionsize
  CC      drivers/net/mii.o
make[4]: *** [drivers/net/ehea/ehea_main.o] Error 1
make[4]: *** Waiting for unfinished jobs....
  CC      drivers/net/ixgb/ixgb_param.o
In file included from /home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:32:
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.h:44:14: warning: "SECTION_SIZE_BITS" is not defined
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.h:45:2: error: #error eHEA module cannot work if kernel sectionsize < ehea sectionsize
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c: In function 'ehea_create_busmap':
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:574: error: 'NR_MEM_SECTIONS' undeclared (first use in this function)
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:574: error: (Each undeclared identifier is reported only once
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:574: error: for each function it appears in.)
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:575: error: implicit declaration of function 'valid_section_nr'
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c: In function 'ehea_map_vaddr':
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:606: error: 'SECTION_SIZE_BITS' undeclared (first use in this function)
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c: In function 'ehea_reg_kernel_mr':
/home/dave/work/linux/2.6/23/linux-2.6.git/drivers/net/ehea/ehea_qmr.c:655: error: 'SECTION_SIZE_BITS' undeclared (first use in this function)

-- Dave

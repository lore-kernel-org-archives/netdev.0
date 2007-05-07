From: Christian Hohnstaedt <chohnstaedt@innominate.com>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 7 May 2007 19:52:13 +0200
Message-ID: <20070507175213.GU23611@tweety>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King <rmk@arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <m3hcqoa772.fsf@maximus.localdomain>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 07:12:49PM +0200, Krzysztof Halasa wrote:
> Michael-Luke Jones <mlj28@cam.ac.uk> writes:
> 
> > Code placement:
> > Queue Manager & NPE code => arch/arm/mach-ixp4xx
> > WAN driver code => drivers/net/wan
> > Eth code => drivers/net/arm
> 
> Why would you want such placement?
> Potential problems: header files would have to be moved to
> include/asm-arm = headers pollution.
> All 4 drivers are, in fact, network (related) drivers.
No.

- qmgr is a versatile hardware fifo stack, that is currently
  used to exchange data with the NPE.

- the NPE can also be used as DMA engine and for crypto operations.
  Both are not network related.
  Additionally, the NPE is not only ixp4xx related, but is
  also used in IXP23xx CPUs, so it could be placed in
  arch/arm/common or arch/arm/xscale ?

- The MAC is used on IXP23xx, too. So the drivers for
  both CPU familys only differ in the way they exchange
  network packets between the NPE and the kernel.
  
> 
> drivers/net/arm would probably make (some) sense if it was
> a single (or not so single) Ethernet driver.
If Queue Manager & NPE move to arch/.... , it can be a single file.

Christian Hohnstaedt

-- 
Christian Hohnstaedt
Software Engineer

Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.6392-3285 fax: +49.30.6392-3307
Albert-Einstein-Strasse 14, D-12489 Berlin, Germany
http://www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Joachim Fietz, Dirk Seewald
Chairman of the Supervisory Board: Edward M. Stadum

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php

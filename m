From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH: 2.6.12-rc1] mv643xx: ethernet driver updates
Date: Mon, 28 Mar 2005 16:38:07 -0700
Message-ID: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

Here are some updates to the Marvell mv643xx Ethernet driver.
Both bug fixes and source code cleanups are included.
Most of these changes were submitted by James Chapman <jchapman@katalix.com>.

I didn't include the gcapatch because it's big and not very useful
since essentially all the functions in drivers/net/mv643xx_eth.c
have been reordered.

I will followup to this message with each individual changeset patch
(except for the code reorder changeset).

These changes depend on the previously accepted patch found in:
http://marc.theaimsgroup.com/?l=linux-netdev&m=111155864303860&w=2

Thank you,
Dale Farnsworth


Please do a

	bk pull bk://dfarnsworth.bkbits.net/linux-2.5-mv643xx-enet

This will update the following files:

 arch/ppc/platforms/katana.c         |   24 
 arch/ppc/platforms/radstone_ppc7d.c |   25 
 drivers/net/Kconfig                 |    2 
 drivers/net/mv643xx_eth.c           | 4186 ++++++++++++++++--------------------
 drivers/net/mv643xx_eth.h           |  235 +-
 include/linux/mv643xx.h             |  204 -
 6 files changed, 2149 insertions(+), 2527 deletions(-)

through these ChangeSets:

<dale@farnsworth.org> (05/03/28 1.2252)
   mv643xx: Fix promiscuous mode handling
   
   mv643xx_eth_get_config_reg() was reading the wrong register.
   mv643xx_eth_set_config_reg() was or'ing instead of setting the
   register.  These functions are trivial and both are called only from
   mv643xx_eth_set_rx_mode() when changing the promiscuous mode.  Remove both
   functions and do the operations directly in mv643xx_eth_set_rx_mode().
   
   Also, maintain promiscuous mode setting across port resets.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2251)
   mv643xx: Ensure NAPI poll routine only clears IRQs handled by itself
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2250)
   mv643xx: Isolate the PHY at device close
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2249)
   mv643xx: Reset the PHY only at driver open time
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2248)
   mv643xx: Limit MTU to 1500 bytes unless connected at GigE speed
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2247)
   mv643xx: Add James Chapman to copyright statement and author list
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2246)
   mv643xx: whitespace and indentation cleanup
   
   Code passed through Lindent to fixup some broken indentation and to
   force consistent use of tabs. Unfortunately, very long macro names
   used for register accesses mean keeping to the 80 char line length
   constraint is impossible so several lines have been manually fixed up
   and are longer than 80 chars.
   
   There are no functional changes in this patch.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2245)
   mv643xx: remove useless function header block comments
   
   This driver was full of big function header block comments with Name,
   Description, Parameter, Input, Output and ReturnValue clauses, most of
   which were completely useless. The parameter tables made the code
   difficult to maintain and they added no value anyway. Where the
   description text was useful, I retained it in a simple comment block
   above the function but (as in most cases) where even the description
   added no value, I simply deleted the whole comment block.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2244)
   mv643xx: reorder code to avoid prototype function declarations where possible.
   
   This patch reorders functions to avoid the need for function
   prototypes. In practice, low-level routines are moved to the top of
   the file and driver API functions to the bottom. This is how most
   Linux drivers are laid out.
   
   There are no functional changes here.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2243)
   mv643xx: rename all functions to have a common mv643xx_eth prefix.
   
   This patch just establishes consistent function naming. No functional
   changes here.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2242)
   mv643xx: compile fix for non-NAPI case.
   
   Compiles for the non-NAPI configuration were broken. 
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2241)
   mv643xx: make internal functions take device pointer param consistently
   
   Some internal driver functions take int port_num as a parameter to
   identify the device. It makes no sense to hide the internal device
   structure data from these routines so pass a pointer to the net_device
   structure instead. Although in many cases the device data is needed only
   to get the port number, this change makes the code more consistent and
   easier to maintain.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2240)
   mv643xx: remove ETH_FUNC_RET_STATUS and unused ETH_TARGET enums.
   
   The ETH_FUNC_RET_STATUS enum makes the driver code look more complex
   than it needs to be so remove it. The ETH_TARGET enum was no longer
   used so that goes as well.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2239)
   mv643xx:  move static prototypes from header file into driver C file.
   
   Static function prototypes don't belong in a header file so move them
   into the driver C file. Also add a check for valid port number at
   device create to catch silly platform data errors.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2238)
   mv643xx: use netif_msg_xxx() to control log messages where appropriate
   
   Network driver messages can be controlled using ethtool msglvl via the
   netif_msg_xxx() macros. This patch allows mv643xx's driver message
   verbosity to be controlled by ethtool.
   
   Some debug messages have also been added (not enabled by default) to
   trace low-level (per packet) device access.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2237)
   ppc32: update ppc7d platform for new mv643xx_eth platform data
   
   This patch updates the ethernet device platform data of Radstone
   PPC7D.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2236)
   ppc32: Update Artesyn katana mv643xx ethernet platform data
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2235)
   mv643xx: use MII library for ethtool functions
   
   Use the common ethtool support functions of the MII library.
   Add generic MII ioctl handler.
   Add PHY parameter (speed/duplex/negotiation etc) modification support.
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2234)
   mv643xx: use MII library for PHY management.
   
   Modify link up/down handling to use the functions from the MII
   library.  Note that I track link state using the MII PHY registers
   rather than the mv643xx chip's link state registers because I think
   it's cleaner to use the MII library code rather than writing local
   driver support code. It is also useful to make the actual MII
   registers available to the user with maskable kernel printk messages
   so the MII registers are being read anyway
   
   Signed-off-by: James Chapman <jchapman@katalix.com>
   Acked-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/03/28 1.2233)
   mv643xx: Add mv643xx_enet support for PPC Pegasos platform
   
   Set SA_SHIRQ flag on call to request_irq()
   
   Add MV643XX_ETH dependency on PPC_MULTIPLATFORM
   
   Signed-off-by: Nicolas DET <nd@bplan-gmbh.de>
   Signed-off-by: Sven Luther <sl@bplan-gmbh.de>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

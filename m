From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu, 6 Mar 2008 15:41:50 -0800
Message-ID: <20080306154150.0ba906fa.akpm@linux-foundation.org>
References: <1204800947-21569-1-git-send-email-jonas@southpole.se>
	<1204800947-21569-2-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, Greg KH <greg@kroah.com>
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55287 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754424AbYCFXvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:51:17 -0500
In-Reply-To: <1204800947-21569-2-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  6 Mar 2008 11:55:39 +0100
Jonas Bonn <jonas@southpole.se> wrote:

> Makes struct pci_device_id array const and moves it to __devinitconst
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>
> ---
>  drivers/net/cassini.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
> index 14299f8..1451533 100644
> --- a/drivers/net/cassini.c
> +++ b/drivers/net/cassini.c
> @@ -233,7 +233,7 @@ static u16 link_modes[] __devinitdata = {
>  	CAS_BMCR_SPEED1000|BMCR_FULLDPLX /* 5 : 1000bt full duplex */
>  };
>  
> -static struct pci_device_id cas_pci_tbl[] __devinitdata = {
> +static DECLARE_PCI_DEVICE_TABLE(cas_pci_tbl) = {
>  	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_CASSINI,
>  	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
>  	{ PCI_VENDOR_ID_NS, PCI_DEVICE_ID_NS_SATURN,

Bah.

a) DECLARE_PCI_DEVICE_TABLE is misnamed.  It is used to *define* tables,
   not to declare them.  It should be called DEFINE_PCI_DEVICE_TABLE.

b) It's lame, anyway.  We could implement any number of such helper
   thingies, but we choose not to.


So I wouldn't go adding code which uses this thing until it has a correct
name, and until we've decided that we actually want to live with it.


Here's the easy part:

 Documentation/pci.txt |    4 ++--
 include/linux/pci.h   |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff -puN Documentation/pci.txt~rename-declare_pci_device_table-to-define_pci_device_table Documentation/pci.txt
--- a/Documentation/pci.txt~rename-declare_pci_device_table-to-define_pci_device_table
+++ a/Documentation/pci.txt
@@ -123,7 +123,7 @@ initialization with a pointer to a struc
 
 
 The ID table is an array of struct pci_device_id entries ending with an
-all-zero entry; use of the macro DECLARE_PCI_DEVICE_TABLE is the preferred
+all-zero entry; use of the macro DEFINE_PCI_DEVICE_TABLE is the preferred
 method of declaring the table.  Each entry consists of:
 
 	vendor,device	Vendor and device ID to match (or PCI_ANY_ID)
@@ -193,7 +193,7 @@ Tips on when/where to use the above attr
 	o Do not mark the struct pci_driver.
 
 	o The ID table array should be marked __devinitconst; this is done
-	  automatically if the table is declared with DECLARE_PCI_DEVICE_TABLE().
+	  automatically if the table is declared with DEFINE_PCI_DEVICE_TABLE().
 
 	o The probe() and remove() functions should be marked __devinit
 	  and __devexit respectively.  All initialization functions
diff -puN include/linux/pci.h~rename-declare_pci_device_table-to-define_pci_device_table include/linux/pci.h
--- a/include/linux/pci.h~rename-declare_pci_device_table-to-define_pci_device_table
+++ a/include/linux/pci.h
@@ -389,13 +389,13 @@ struct pci_driver {
 #define	to_pci_driver(drv) container_of(drv, struct pci_driver, driver)
 
 /**
- * DECLARE_PCI_DEVICE_TABLE - macro used to describe a pci device table
+ * DEFINE_PCI_DEVICE_TABLE - macro used to describe a pci device table
  * @_table: device table name
  *
  * This macro is used to create a struct pci_device_id array (a device table)
  * in a generic manner.
  */
-#define DECLARE_PCI_DEVICE_TABLE(_table) \
+#define DEFINE_PCI_DEVICE_TABLE(_table) \
 	const struct pci_device_id _table[] __devinitconst
 
 /**
_


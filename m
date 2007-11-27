From: tony@bakeyournoodle.com (Tony Breeds)
Subject: Re: mm snapshot broken-out-2007-11-20-01-45 Build Fail - net/wireless driver
Date: Tue, 27 Nov 2007 11:59:50 +1100
Message-ID: <20071127005950.GZ24243@bakeyournoodle.com>
References: <200711200953.lAK9qxjO030444@imap1.linux-foundation.org> <4742DFC3.80305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	linux-kernel@vger.kernel.org, mick@madwifi.org,
	netdev@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758001AbXK0BAF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4742DFC3.80305@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 06:53:15PM +0530, Kamalesh Babulal wrote:
> Hi Andrew,
> 
> The kernel build fails, with following message
> 
>   LD      drivers/net/wireless/built-in.o
> drivers/net/wireless/rtl8187.o: In function `rtl8225z2_rf_init':
> (.opd+0x180): multiple definition of `rtl8225z2_rf_init'
> drivers/net/wireless/rtl8180.o:(.opd+0x1b0): first defined here
> drivers/net/wireless/rtl8187.o: In function `rtl8225z2_rf_init':
> /root/linux-2.6.24-rc3/drivers/net/wireless/rtl8187_rtl8225.c:571: multiple definition of `.rtl8225z2_rf_init'
> drivers/net/wireless/rtl8180.o:/root/linux-2.6.24-rc3/drivers/net/wireless/rtl8180_rtl8225.c:561: first defined here
> ld: Warning: size of symbol `.rtl8225z2_rf_init' changed from 3836 in drivers/net/wireless/rtl8180.o to 3544 in drivers/net/wireless/rtl8187.o

<snip>

The patch below is a little ugly but will allow allyesconfig to work.  I
don't know enough about the Realtek devices to make intellegent
suggestions on how to fix this particular problem.  Clearly the 2
drivers share a lot of common code so perhaps they can be merged?

I assumed that the RTL8180, is still somewhat WiP based on the commit
message for a2645795713c4374ff2efda960251cdc30b63430 (wireless-2.6.git).

Appologies for the uber long CC line, wasn't sure who can be pruned.

From: Tony Breeds <tony@bakeyournoodle.com>

Temporarily ensure that Realtek 8185 and 8187 aren't compiled together.

These two drivers share a number of common (global) functions.  While RTL8180
is still being worked on ensure that it's not built together with the RTL8187
(ie allyseconfig).

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>

---

 drivers/net/wireless/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 82e5de7..ab2eac0 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -555,6 +555,7 @@ config USB_ZD1201
 config RTL8180
 	tristate "Realtek 8185 PCI support"
 	depends on MAC80211 && PCI && WLAN_80211 && EXPERIMENTAL
+	depends on !RTL8187
 	select EEPROM_93CX6
 
 config RTL8187

Yours Tony

  linux.conf.au        http://linux.conf.au/ || http://lca2008.linux.org.au/
  Jan 28 - Feb 02 2008 The Australian Linux Technical Conference!

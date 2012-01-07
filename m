From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 0/2] igb: ptp hardware clock
Date: Sat,  7 Jan 2012 20:38:19 +0100
Message-ID: <cover.1325964581.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

* ChangeLog
** V3
   - Driver compiles even without CONFIG_PTP_1588_CLOCK.
   - Timestamping always works, even when PTP code missing or fails.
** V2
   - Fixed wrong bit shifting in the 82576 code.
   - Explained the timestamp locking with a comment in the code.
   - Preserved the comments from the original timecompare implementation.
   - Added an additional test within the overflow counter code to fix
     a race condition. Details of the problem are given in the commit
     message.

This patch series implements a PHC driver for the Intel 82576 and
82580 devices, as part of the igb driver.

The first patch adds the PHC driver code as a new source module but
does not link it into the main igb driver. Because the system time
counter is not so very wide, the code implements an overflow counter
in software. Every read operation maintains the overflow counter, as
does a "delayed work" watchdog. Only the base clock operations are
implemented. The hardware does have some ancillary features, but these
can be easily added later.

The second patch removes the timecompare code and links in the new
functions.

I have tested the 82580 with good results. However, I don't have the
82576 and so would appreciate testing and feedback.

Thanks,
Richard


Richard Cochran (2):
  igb: add PTP Hardware Clock code
  igb: offer a PTP Hardware Clock instead of the timecompare method

 drivers/net/ethernet/intel/igb/Makefile   |    2 +-
 drivers/net/ethernet/intel/igb/igb.h      |   21 +-
 drivers/net/ethernet/intel/igb/igb_main.c |  167 +----------
 drivers/net/ethernet/intel/igb/igb_ptp.c  |  493 +++++++++++++++++++++++++++++
 4 files changed, 512 insertions(+), 171 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c

-- 
1.7.2.5


------------------------------------------------------------------------------
Ridiculously easy VDI. With Citrix VDI-in-a-Box, you don't need a complex
infrastructure or vast IT resources to deliver seamless, secure access to
virtual desktops. With this all-in-one solution, easily deploy virtual 
desktops for less than the cost of PCs and save 60% on VDI infrastructure 
costs. Try it free! http://p.sf.net/sfu/Citrix-VDIinabox
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

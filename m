From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion
	timout on Pseries HW
Date: Thu, 17 May 2007 10:01:19 +0100
Message-ID: <20070517090119.GA27145@infradead.org>
References: <20070516085329.29131.120.stgit@localhost.localdomain>
	<495A2DE1-775D-4DFC-9C1C-4644AA5A040B@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>, jeff@garzik.org,
	wenxiong@us.ibm.com
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <495A2DE1-775D-4DFC-9C1C-4644AA5A040B@kernel.crashing.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 07:43:27PM -0500, Kumar Gala wrote:
> >index 49be393..830d851 100644
> >--- a/drivers/net/e1000/e1000_main.c
> >+++ b/drivers/net/e1000/e1000_main.c
> >@@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
> > 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
> > 	}
> >
> >+#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
> 
> If this is really on need on pseries HW this should be #ifdef  
> CONFIG_PPC_PSERIES.  No reason to force this on all PPC.

No, it shouldn't.  powerpc kernels are multi-platform.

It really shouldn't be there at all because something in either the intel
or pseries hardware is totally buggy and we should disable features in
the buggy one completely.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

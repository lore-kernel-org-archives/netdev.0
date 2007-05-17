From: Wen Xiong <wenxiong@us.ibm.com>
Subject: Re: [PATCH] e1000: Work around 82571 completion
	timout on Pseries HW
Date: Thu, 17 May 2007 09:58:03 -0500
Message-ID: <OFDD90D73E.30B0DB27-ON872572DE.004ED0BE-862572DE.005242EA@us.ibm.com>
References: <20070517090119.GA27145@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1069050782=="
Cc: wendyx@linux.vnet.ibm.com, Auke Kok <auke-jan.h.kok@intel.com>,
	jeff@garzik.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Kumar Gala <galak@kernel.crashing.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070517090119.GA27145@infradead.org>
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

This is a multipart message in MIME format.
--===============1069050782==
Content-Type: multipart/alternative;
	boundary="=_alternative 005242E8862572DE_="

This is a multipart message in MIME format.
--=_alternative 005242E8862572DE_=
Content-Type: text/plain; charset="US-ASCII"

>>It really shouldn't be there at all because something in either the 
intel
>>or pseries hardware is totally buggy and we should disable features in
>>the buggy one completely.

Hi,

Here there are not hardware issue on both Intel or PPC.  The patch is to 
work around a loop hold on early version of PCI SGI spec. 
The later PCI Sgi have spec have corrected it.  We can just implement it 
for PPC only.  Other vendor may have the same issue.

Thanks,
wendy




Christoph Hellwig <hch@infradead.org> 
05/17/2007 04:01 AM

To
Kumar Gala <galak@kernel.crashing.org>
cc
Auke Kok <auke-jan.h.kok@intel.com>, jeff@garzik.org, Wen 
Xiong/Austin/IBM@IBMUS, e1000-devel@lists.sourceforge.net, 
netdev@vger.kernel.org
Subject
Re: [PATCH] e1000: Work around 82571 completion timout on Pseries HW






On Wed, May 16, 2007 at 07:43:27PM -0500, Kumar Gala wrote:
> >index 49be393..830d851 100644
> >--- a/drivers/net/e1000/e1000_main.c
> >+++ b/drivers/net/e1000/e1000_main.c
> >@@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
> >                              E1000_WRITE_REG(&adapter->hw, CTRL, 
ctrl);
> >              }
> >
> >+#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
> 
> If this is really on need on pseries HW this should be #ifdef 
> CONFIG_PPC_PSERIES.  No reason to force this on all PPC.

No, it shouldn't.  powerpc kernels are multi-platform.

It really shouldn't be there at all because something in either the intel
or pseries hardware is totally buggy and we should disable features in
the buggy one completely.



--=_alternative 005242E8862572DE_=--


--===============1069050782==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1069050782==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--===============1069050782==--

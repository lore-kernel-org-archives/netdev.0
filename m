From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Work around 82571 completion
	timout on Pseries HW
Date: Sat, 23 Jun 2007 10:05:08 -0700
Message-ID: <467D52C4.6010905@intel.com>
References: <20070517090119.GA27145@infradead.org>
	<OFDD90D73E.30B0DB27-ON872572DE.004ED0BE-862572DE.005242EA@us.ibm.com>
	<20070623082003.GA29471@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wendyx@linux.vnet.ibm.com, Auke Kok <auke-jan.h.kok@intel.com>,
	jeff@garzik.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Kumar Gala <galak@kernel.crashing.org>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <20070623082003.GA29471@infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Thu, May 17, 2007 at 09:58:03AM -0500, Wen Xiong wrote:
>>>> It really shouldn't be there at all because something in either the 
>> intel
>>>> or pseries hardware is totally buggy and we should disable features in
>>>> the buggy one completely.
>> Hi,
>>
>> Here there are not hardware issue on both Intel or PPC.  The patch is to 
>> work around a loop hold on early version of PCI SGI spec. 
>> The later PCI Sgi have spec have corrected it.  We can just implement it 
>> for PPC only.  Other vendor may have the same issue.
> 
> In this case we should add a blacklist for implementations of the old
> spec.  There should be a way to find specific bridges in the OF firmware
> tree on powerpc and similar things on other platforms aswell.

Yes, this is almost what we did.

IBM is currently testing my patches that implement a generic pci quirk that will 
be enabled for only selected root complex ID's that require the (1.0a spec) 
device to disable the completion timeouts.

They are currently validating this test on the affected hardware. I expect to 
get the results within a week and then I will post the patch.

Since this is one of the few holes in between the two specs (where manual 
intervention is needed) I think that a single quirk is a fairly sane approach.

Cheers,

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

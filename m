From: Michael Iatrou <m.iatrou@freemail.gr>
Subject: Re: [E1000-devel] Page Allocation Failure with e1000 using jumbo frame
Date: Sat, 20 Aug 2005 04:43:40 +0300
Message-ID: <200508200443.40251.m.iatrou@freemail.gr>
References: <1124326404.5546.215.camel@localhost.localdomain> <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ming Zhang <mingz@ele.uri.edu>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <iscsitarget-devel-admin@lists.sourceforge.net>
To: e1000-devel@lists.sourceforge.net
In-Reply-To: <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
Content-Disposition: inline
Sender: iscsitarget-devel-admin@lists.sourceforge.net
Errors-To: iscsitarget-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:iscsitarget-devel@lists.sourceforge.net>
List-Help: <mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=iscsitarget-devel>
List-Id: netdev.vger.kernel.org

When the date was Friday 19 August 2005 19:51, Jesse Brandeburg wrote:

> included netdev...
>
> On Wed, 17 Aug 2005, Ming Zhang wrote:
> > Hi folks
> >
> > We ran into this problem when running jumbo frame with iscsi over e1000.
> > the MTU1500 is fine while jumbo frame can stably reproduce this error.
> >
> > when meet this error, as reported in iet list, the box still has >600MB
> > ram free. also the slab is not heavily used.
> >
> > any idea on this?
>
> So, what we do know is that your kernel memory manager is (for whatever
> unknown reason) having trouble finding contiguous 2^3 pages (32kB) chunks
> of memory.  This occurs because we need to give our hardware 16kB
> contiguous (currently, we actually have a patch for this in internal
> testing) which means that when we do dev_alloc_skb, it allocates 16kB + 16
> bytes reserve, plus 2 bytes NET_IP_ALIGN, which takes us into the 32kB
> slab (power of two roundup)

I don't get it: For MTU = 9000, you already have to allocate 2^3 pages, but 
testing shows that the problem only occurs for MTU > 3*PAGE_SIZE

http://members.hellug.gr/iatrou/plain_ip_mtu.png

(reference to previous discussion)
http://sourceforge.net/mailarchive/forum.php?forum_id=12401&max_rows=25&style=ultimate&viewmonth=200505

-- 
 Michael Iatrou
 Electrical and Computer Engineering Dept.
 University of Patras, Greece


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf

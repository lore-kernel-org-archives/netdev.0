From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: Expose ltr/obff interface by sysfs
Date: Fri, 6 Apr 2012 14:39:32 -0400
Message-ID: <20120406183932.GB13473@phenom.dumpdata.com>
References: <403610A45A2B5242BD291EDAE8B37D300FD0A434@SHSMSX102.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Hao, Xudong" <xudong.hao@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <403610A45A2B5242BD291EDAE8B37D300FD0A434@SHSMSX102.ccr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Apr 06, 2012 at 02:43:59AM +0000, Hao, Xudong wrote:
> Hi, 
> 
> I'm working on virtualization Xen/KVM. I saw there are ltr/obff enabling/disabling function in pci.c, but no called till now. I want to know if anybody(driver developer) are working for using it? Can driver change the LTR latency value dynamically?
> 
> /*
> LTR(Latency tolerance reporting) allows devices to send messages to the root complex indicating their latency tolerance for snooped & unsnooped memory transactions.
> OBFF (optimized buffer flush/fill), where supported, can help improve energy efficiency by giving devices information about when interrupts and other activity will have a reduced power impact.
> */
> 
> One way to control ltr/obff is used by driver, however, I'm considering that in virtualization, how guest OS driver control them. I have an idea that expose an inode interface by sysfs, like "reset" inode implemented in pci-sysfs.c, so that system user/administrator can enable/disable ltr/obff or set latency value on userspace, but not limited on driver. Comments?

So right now the driver inside the guest can probably see it, but can't change them.
(As those requests end up being filtered).

But there is nothing wrong with your changing those values from within the host.

But a better question is - why should this be done - especially from the guest which
has a limited view of the machine? The machine might be running a lot of other
requests so the OBFF inside the guest could be invalid.


> 
> < pls CC me when reply this mail, thanks >
> 
> Best Regards,
> Xudong Hao
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

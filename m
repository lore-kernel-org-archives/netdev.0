From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 9/9] netconsole: Support dynamic reconfiguration
 using configfs
Date: Fri, 13 Jul 2007 22:50:16 +0900
Message-ID: <46978318.9080804@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710092006.23907.33652.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:57580 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757415AbXGMNuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 09:50:19 -0400
In-Reply-To: <20070710092006.23907.33652.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [9/9] netconsole: Support dynamic reconfiguration using configfs
> 
> This patch introduces support for dynamic reconfiguration (adding, removing
> and/or modifying parameters of netconsole targets at runtime) using a
> userspace interface exported via configfs. Documentation is also updated
> accordingly.
> 
> Issues and brief design overview:
> 
> (1) Kernel-initiated creation / destruction of kernel objects is not
> possible with configfs -- the lifetimes of the "config items" is managed
> exclusively from userspace. But netconsole must support boot/module params
> too, and these are parsed in kernel and hence netpolls must be setup from
> the kernel. Joel Becker suggested to separately manage the lifetimes of
> the two kinds of netconsole_target objects -- those created via configfs
> mkdir(2) from userspace and those specified from the boot/module option
> string. This adds complexity and some redundancy here and also means that
> boot/module param-created targets are not exposed through the configfs
> namespace (and hence cannot be updated / destroyed dynamically). However,
> this saves us from locking / refcounting complexities that would need to
> be introduced in configfs to support kernel-initiated item creation /
> destroy there. Also, this is similar to present behaviour in any case so
> not really a problem.
> 
> (2) In configfs, item creation takes place in the call chain of the mkdir(2)
> syscall in the driver subsystem. If we used an ioctl(2) to create / destroy
> objects from userspace, the special userspace program is able to fill out
> the structure to be passed into the ioctl and hence specify attributes such
> as local interface that are required at the time we set up the netpoll.
> For configfs, this information is not available at the time of mkdir(2).
> So, we keep all newly-created targets (via configfs) disabled by default.
> The user is expected to set various attributes appropriately (including the
> local network interface if required) and then write(2) "1" to the "enabled"
> attribute. Thus, netpoll_setup() is then called on the set parameters in the
> context of _this_ write(2) on the "enabled" attribute itself. This design
> enables the user to reconfigure existing netconsole targets at runtime to
> be attached to newly-come-up interfaces that may not have existed when
> netconsole was loaded or when the targets were actually created. This all
> enables us to get rid of custom ioctls.
> 
> (3) Ultra-paranoid configfs attribute show() and store() operations, with
> sanity and input range checking, using only safe string primitives, and
> compliant with the recommendations in Documentation/filesystems/sysfs.txt.
> 
> (4) A new function netpoll_print_options() is created in the netpoll API,
> that just prints out the configured parameters for a netpoll structure.
> netpoll_parse_options() is modified to use that and it is also exported to
> be used from netconsole.
> 
> Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Thanks
--
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com



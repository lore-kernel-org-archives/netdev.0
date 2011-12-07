From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Tue, 06 Dec 2011 20:14:28 -0800
Message-ID: <1323231268.1762.19.camel@joe2Laptop>
References: <4EDED071.40900@linux.vnet.ibm.com>
	 <1323229439.2415.23.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Wang <wangyun@linux.vnet.ibm.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49537 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754697Ab1LGEOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 23:14:30 -0500
In-Reply-To: <1323229439.2415.23.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-06 at 19:43 -0800, Jeff Kirsher wrote:
> On Tue, 2011-12-06 at 18:33 -0800, Michael Wang wrote:
> > From: Michael Wang <wangyun@linux.vnet.ibm.com>
> > Use true and false instead of 1 and 0 when assign value to a bool type
> > variable.
> Thanks Michael, I have added your patch to my queue of e1000e patches.

There are more of these uses in intel drivers.

Perhaps you could run this cocci/spatch
on drivers/net/ethernet/intel/...

$ cat bool.cocci
@@
bool b;
@@

-b = 0;
+b = false;

@@
bool b;
@@

-b = 1;
+b = true;

$ git ls-files drivers/net/ethernet/intel/ | grep "\.c$" | while read file ; do spatch -in_place -sp_file bool.cocci $file ; done

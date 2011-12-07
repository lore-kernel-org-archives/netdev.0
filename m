From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Wed, 07 Dec 2011 12:49:35 +0800
Message-ID: <4EDEF05F.4020901@linux.vnet.ibm.com>
References: <4EDED071.40900@linux.vnet.ibm.com> <1323229439.2415.23.camel@jtkirshe-mobl> <1323231268.1762.19.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:56313 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702Ab1LGEtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 23:49:45 -0500
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 7 Dec 2011 10:19:42 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB74nclJ3739858
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 10:19:39 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB74nbfr018605
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 15:49:38 +1100
In-Reply-To: <1323231268.1762.19.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2011 12:14 PM, Joe Perches wrote:

> On Tue, 2011-12-06 at 19:43 -0800, Jeff Kirsher wrote:
>> On Tue, 2011-12-06 at 18:33 -0800, Michael Wang wrote:
>>> From: Michael Wang <wangyun@linux.vnet.ibm.com>
>>> Use true and false instead of 1 and 0 when assign value to a bool type
>>> variable.
>> Thanks Michael, I have added your patch to my queue of e1000e patches.
> 
> There are more of these uses in intel drivers.
> 
> Perhaps you could run this cocci/spatch
> on drivers/net/ethernet/intel/...
> 
> $ cat bool.cocci
> @@
> bool b;
> @@
> 
> -b = 0;
> +b = false;
> 
> @@
> bool b;
> @@
> 
> -b = 1;
> +b = true;
> 
> $ git ls-files drivers/net/ethernet/intel/ | grep "\.c$" | while read file ; do spatch -in_place -sp_file bool.cocci $file ; done
> 
> 

Hi, Joe

I think there are lots of such cases in kernel, and I think it is a
legacy issue with some story in it.

The reason I only change the e1000e is that the patch I send before will
broken the style of e1000e, because it's using true and false, not 1 and 0.

I think this will be a huge work if we want to correct all these cases,
and I think the good way is to separate the work to small pieces and
finish them slowly.

Thanks,
Michael Wang

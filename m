From: David Miller <davem@davemloft.net>
Subject: Re: Regression: "rtnetlink: Compute and store minimum ifinfo dump
 size" breaks glibc's getifaddrs()
Date: Mon, 30 Jan 2012 11:58:00 -0500 (EST)
Message-ID: <20120130.115800.2216939902996648062.davem@davemloft.net>
References: <4F229A5F.4050600@citrix.com>
	<20120127.165357.462031319592012792.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A07012CCF52@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, netdev@vger.kernel.org, steweg@gmail.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876Ab2A3Q6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 11:58:08 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A07012CCF52@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Mon, 30 Jan 2012 16:50:58 +0000

> Maybe we should have 'ip link show' just display the number of VFs
> and then have a new 'ip' tool syntax along the lines of 'ip link
> show eth(x) vf (n)' where eth(x) is the PF and n is the number of
> the VF.  Then it could show all relevant information for just that
> VF.  Scripts could parse the number of VFs from the first call to
> 'ip link show' and then loop to show the details of each VF.
> 
> Just an idea... maybe there are other ones out there but it's just
> getting ridiculous how much data has to be transferred back and
> forth during the basic 'ip link show' command when the interface as
> subordinate VFs now that we're getting to devices with up to 256
> VFs.

The fix is almost certainly that we need to require that the application
turn on the publishing of features it is interested in.

The inet_diag sockets do something like this, wherein you set bits in
some flags of the request saying what attributes you want to see.

It seems clear that we must, at this point, turn off VF attributes by
default.

Could you do some work on this?  If you don't have the time I'll look
into it, because we'll need to backport this to -stable too.

Thanks.

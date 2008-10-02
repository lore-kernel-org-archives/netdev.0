From: Patrick McManus <mcmanus@ducksong.com>
Subject: RE: 2.6.27 problem with shaping using netem/ifb (regression?) [TSO]
Date: Wed, 01 Oct 2008 21:55:42 -0400
Message-ID: <1222912542.6395.30.camel@tng>
References: <1222902286.6395.22.camel@tng>
	 <36D9DB17C6DE9E40B059440DB8D95F52064FB007@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:34065 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbYJBBzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:55:45 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52064FB007@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-01 at 18:42 -0700, Brandeburg, Jesse wrote:
> > Any thoughts on where to look? I hope attaching the script is helpful
> -
> > it is pretty self evident when running it if things are working ok.
> > This
> > is all on amd64 if that is relevant.
> 
> Have you tried disabling TSO and/or GSO on the loopback device?

for some reason with loopback that didn't come to mind. It's a good
suggestion, and indeed is the crux of the problem. Thanks!

Disabling TSO (ethtool -K lo tso off) fixes the problem. GSO has no
impact.

probly not relevant, but worth noting - the scripts also set the MTU of
lo to 1500 down from the default 16436



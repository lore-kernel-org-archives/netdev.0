From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management
Date: Fri, 20 Mar 2009 09:24:34 -0700
Message-ID: <20090320092434.7ac1baf3@nehalam>
References: <20090319233404.6697768b@nehalam>
	<20090319233610.51fe4ee1@nehalam>
	<Pine.WNT.4.64.0903200019240.14460@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41326 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbZCTQYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 12:24:42 -0400
In-Reply-To: <Pine.WNT.4.64.0903200019240.14460@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009 00:23:39 -0700 (Pacific Daylight Time)
"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com> wrote:

> On Thu, 19 Mar 2009, Stephen Hemminger wrote:
> 
> > Convert ixgbe to use net_device_ops properly.
> > Rather than changing the select_queue function pointer
> > just check the flag.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Thanks Stephen.  I was looking at reassigning a DCB netdev_ops struct when 
> DCB is enabled, and then having a default netdev_ops struct when it's not 
> enabled.  I agree the check is cleaner the way you have it below, but it's 
> another conditional check in the Tx hotpath, which we have too many of in 
> the first place.

Changing number of tx queues is actually the fastest, since then
indirection is not needed

> On a related side note, why is the netdev_ops member of net_device 
> declared const?

The purpose of having an ops structure is two fold. First, the ops
can be in read-only section (if driver wants) to avoid cache issues.
More importantly only one instance is necessary when there are multiple
boards, or 1000's of vlans.

> Cheers,
> -PJ Waskiewicz

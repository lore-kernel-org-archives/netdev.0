From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [RFC 1/4] net: support per queue tx_usecs in sysfs
Date: Tue, 1 Dec 2015 15:44:54 -0800
Message-ID: <20151201154454.000041a3@unknown>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
	<565E1B8E.4040603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <kan.liang@intel.com>, <netdev@vger.kernel.org>,
	<intel-wired-lan@lists.osuosl.org>, <davem@davemloft.net>,
	<andi@firstfloor.org>, <jeffrey.t.kirsher@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <matthew.vick@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<john.r.fastabend@intel.com>, <ogerlitz@mellanox.com>,
	<edumazet@google.com>, <jiri@mellanox.com>, <sfeldma@gmail.com>,
	<gospo@cumulusnetworks.com>, <sasha.levin@oracle.com>,
	<dsahern@gmail.com>, <tj@kernel.org>, <cascardo@redhat.com>,
	<corbet@lwn.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58577 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178AbbLAXoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 18:44:55 -0500
In-Reply-To: <565E1B8E.4040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Dec 2015 14:13:34 -0800
Florian Fainelli <f.fainelli@gmail.com> wrote:

> On 01/12/15 00:01, kan.liang@intel.com wrote:
> > From: Kan Liang <kan.liang@intel.com>
> > 
> > Network devices usually have many queues. Each queue has its own
> > tx_usecs options. Currently, we can only set all the queues with same
> > value by ethtool. This patch expose the tx_usecs in sysfs. So the user
> > can set/get per queue coalesce parameter tx_usecs by sysfs.
> 
> The new interface you propose makes things inconsistent, since we have
> two separate configuration paths (sysfs and ethtool), and it would seem
> better to have per-queue awareness in ethtool, since there is a whole
> bunch of other parameters that could be configured on a per-queue basis.
> 
> Have you tried to extend existing ethtool interfaces to cover the need
> for multiple queues?

While I agree that ethtool provides a similar functionality, ethtool
was designed (particularly the ethtool -C/c commands) around one queue
NICs.  We can't change the output or functionality of the user
interface without breaking a bunch of user's scripts and stuff.

With this effort, Kan is laying groundwork for making further kernel
changes, and having the kernel call back in to drivers via ethtool
mechanisms that were designed before multiple queue adapters.

We can also next migrate the legacy ethtool interfaces to use these
new .ndo_ops should we wish.

These patches were provided with the intent of getting some feedback
about going down this path of making a *consistent* user interface that
is driver agnostic in sysfs, and supports multiple queue adapters.

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [PATCH 2/7] net: dcbnl, add multicast group for DCB
Date: Sun, 19 Jun 2011 21:14:39 +0300
Message-ID: <1308507279.15528.14.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
 <20110617211618.26578.34100.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4209 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078Ab1FSQYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 12:24:33 -0400
In-Reply-To: <20110617211618.26578.34100.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2011-06-17 at 14:16 -0700, John Fastabend wrote:
> Now that dcbnl is being used in many cases by more
> than a single agent it is beneficial to be notified
> when some entity either driver or user space has
> changed the DCB attributes.
> 
> Today applications either end up polling the interface
> or relying on a user space database to maintain the DCB
> state and post events. Polling is a poor solution for
> obvious reasons. And relying on a user space database
> has its own downside. Namely it has created strange
> boot dependencies requiring the database be populated
> before any applications dependent on DCB attributes
> starts or the application goes into a polling loop.
> Populating the database requires negotiating link
> setting with the peer and can take anywhere from less
> than a second up to a few seconds depending on the switch
> implementation.
> 
> Perhaps more importantly if another application or an
> embedded agent sets a DCB link attribute the database
> has no way of knowing other than polling the kernel.
> This prevents applications from responding quickly to
> changes in link events which at least in the FCoE case
> and probably any other protocols expecting a lossless
> link may result in IO errors.
> 
> By adding a multicast group for DCB we have clean way
> to disseminate kernel DCB link attributes up to user
> space. Avoiding the need for user space to maintain
> a coherant database and disperse events that potentially
> do not reflect the current link state.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  include/linux/rtnetlink.h |    2 
>  net/dcb/dcbnl.c           |  228 +++++++++++++++++++++++++++++----------------
>  2 files changed, 147 insertions(+), 83 deletions(-)
> 
[...]
> +static int dcbnl_notify(struct net_device *dev, int event, int cmd,
> +			u32 seq, u32 pid)
[...]
A driver supporting an embedded dcbx stack would want to directly invoke
the notification routine, therefore it should be exported. I'd like also
to add support for a CEE notification. Also when the driver invokes the
notification shouldn't it use a new event type something like
RTM_NEWDCB?
 



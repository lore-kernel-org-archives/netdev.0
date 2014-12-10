From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: xen-netback: make feature-rx-notify mandatory -- Breaks stubdoms
Date: Wed, 10 Dec 2014 15:07:19 +0000
Message-ID: <1418224039.3505.76.camel@citrix.com>
References: <54884DA8.7030003@nuclearfallout.net>
	 <548854C3.7060008@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John <jw@nuclearfallout.net>,
	"Xen-devel@lists.xen.org" <Xen-devel@lists.xen.org>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:31982 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757519AbaLJPLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 10:11:23 -0500
In-Reply-To: <548854C3.7060008@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-10 at 14:12 +0000, David Vrabel wrote:
> On 10/12/14 13:42, John wrote:
> > David,
> > 
> > This patch you put into 3.18.0 appears to break the latest version of
> > stubdomains. I found this out today when I tried to update a machine to
> > 3.18.0 and all of the domUs crashed on start with the dmesg output like
> > this:
> 
> Cc'ing the lists and relevant netback maintainers.
> 
> I guess the stubdoms are using minios's netfront?  This is something I
> forgot about when deciding if it was ok to make this feature mandatory.

Oh bum, me too :/

> The patch cannot be reverted as it's a prerequisite for a critical
> (security) bug fix.  I am also unconvinced that the no-feature-rx-notify
> support worked correctly anyway.
> 
> This can be resolved by:
> 
> - Fixing minios's netfront to support feature-rx-notify. This should be
> easy but wouldn't help existing Xen deployments.

I think this is worth doing in its own right, but as you say it doesn't
help existing users.

> - Reimplement feature-rx-notify support.  I think the easiest way is to
> queue packets on the guest Rx internal queue with a short expiry time.

Right, I don't think we especially need to make this case good (so long
as it doesn't reintroduce a security hole!).

In principal we aren't really obliged to queue at all, but since all the
infrastructure for queuing and timing out all exists I suppose it would
be simple enough to implement and a bit less harsh.

Given we now have XENVIF_RX_QUEUE_BYTES and rx_drain_timeout_jiffies we
don't have the infinite queue any more. So does the expiry in this case
actually need to be shorter than the norm? Does it cause any extra
issues to keep them around for tx_drain_timeout_jiffies rather than some
shorter time?

Ian.

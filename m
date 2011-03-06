From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge
 changes state
Date: Sun, 6 Mar 2011 09:45:41 -0800
Message-ID: <20110306094541.53390b55@nehalam>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
	<1154832100.13939.1299393783798.JavaMail.root@tahiti.vyatta.com>
	<20110306080328.GA3850@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Adam Majer <adamm@zombino.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34094 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772Ab1CFRpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 12:45:44 -0500
In-Reply-To: <20110306080328.GA3850@mira.lan.galacticasoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 6 Mar 2011 02:03:28 -0600
Adam Majer <adamm@zombino.com> wrote:

> On Sat, Mar 05, 2011 at 10:43:03PM -0800, Stephen Hemminger wrote:
> > Why not set forwarding delay to zero? I don't think you are using STP?
> > 
> > P.s: removing linux-kernel mailing list, since there is no point
> > in copying the whole world on this thread.
> 
> I just sent patches where MAINTAINERS file told me to send it. ;)
> 
> No, I'm not relying on STP. I think setting learning->forwarding delay
> to 0 could cause problems with STP like loops until the loop is
> detected.
> 
> There may be a better spot where to insert the notification that the
> bridge is forwarding data, though I'm not exactly certain where. The
> patch will cause bridge to issue NETDEV_CHANGE notification for all
> topology changes. This may or may not be useful but shouldn't be
> harmful (I can't imagine these occur very often?) The IPv6 autoconf
> patch will only act on this if it doesn't have IPv6 address configured
> manually or via autoconf.
> 

Since this a generic problem, it needs a better solution.
Sending NETDEV_CHANGE impacts lots of other pieces, and even
user space has similar problems.

-- 

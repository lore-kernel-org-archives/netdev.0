From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Tue, 29 May 2012 15:33:48 -0400
Message-ID: <20120529193348.GB9258@hmsreliant.think-freely.org>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
 <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
 <20120517.160937.586334759945738635.davem@davemloft.net>
 <20120517202152.GB19321@hmsreliant.think-freely.org>
 <1337691919.3361.189.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36149 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363Ab2E2Tdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 15:33:55 -0400
Content-Disposition: inline
In-Reply-To: <1337691919.3361.189.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 22, 2012 at 03:05:19PM +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 16:21 -0400, Neil Horman wrote:
> > On Thu, May 17, 2012 at 04:09:37PM -0400, David Miller wrote:
> 
> > > 
> > > Applied, althrough it didn't apply cleanly to net-next.
> > > 
> > 
> > Apologies Dave, should have told you that I was carrying Joe P.'s cleanup patch
> > in my net-next tree as well:
> > http://marc.info/?l=linux-netdev&m=133727344816140&w=2
> > 
> > Since you noted that you had applied it, I applied it myself here.
> > Neil
> > 
> 
> Any plan to autoload drop_monitor module from dropwatch,
> or issuing some advice ?
> 
> # dropwatch -l kas
> Unable to find NET_DM family, dropwatch can't work
> Cleanuing up on socket creation error
> 
> Thanks
> 
> 
> 

Eric,
	Just FYI, I sent a series upstream to implement autoloading of generic
netlink families.  Please be awarem, that I've tested these with a hacked
version of dropwatch, and it works great, but with the normal version of
dropwatch, the drop_monitor module still doesn't autoload.  This is due to libnl
not explicitly requesting a family when genl_ctrl_family_resolve is called.
Instead of trying to load the module, it dumps the existing registered families
via a NLM_F_DUMP message.  I'm working on updating libnl to correct this
currently and will cc you on the patch.
Neil

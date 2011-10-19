From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Wed, 19 Oct 2011 13:12:52 -0700
Message-ID: <1319055172.7658.33.camel@HP1>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
 <20111019.160653.684945718064985511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4071 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753538Ab1JSUWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 16:22:55 -0400
In-Reply-To: <20111019.160653.684945718064985511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2011-10-19 at 13:06 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 13 Oct 2011 20:38:01 -0700
> 
> > From: Dmitry Kravkov <dmitry@broadcom.com>
> > 
> > For an FCoE or iSCSI boot device, the networking side must stay "up" all
> > the time.  Otherwise, the FCoE/iSCSI interface driven by bnx2i/bnx2fc
> > will be reset and we'll lose the root file system.
> > 
> > If LRO is enabled, scripts that enable IP forwarding or bridging will
> > disable LRO and cause the device to be reset.  Disabling LRO on these
> > boot devices will prevent the reset.
> > 
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> You're still going to have bugs after this.
> 
> What if you get a FIFO overflow or other error condition which requires
> a chip reset?  You'll lose the root filesystem.

That would be no different than a scsi driver experiencing fatal errors,
wouldn't it?

>   Why bother resetting
> the chip at all if it's going to be useless afterwards?

If the user has configured multipath to the storage target, we can still
reset each port separately.

What we want to prevent is any hidden reset during normal operations.

> 
> The bug is in the fact that iSCSI context state isn't preserved or
> reloaded across a chip reset.
> 
> Please fix that instead, and that way you won't have to add special
> hacks for the root filesystem.  Everything will "just work'.
> 
> 

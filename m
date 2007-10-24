From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Tue, 23 Oct 2007 20:42:27 -0400
Message-ID: <471E94F3.5050407@garzik.org>
References: <1192667871139-git-send-email-fubar@us.ibm.com> <1192667875793-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58954 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbXJXAma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 20:42:30 -0400
In-Reply-To: <1192667875793-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Convert bonding timers to workqueues.  This converts the various
> monitor functions to run in periodic work queues instead of timers.  This
> patch introduces the framework and convers the calls, but does not resolve
> various locking issues, and does not stand alone.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_3ad.c   |    6 +-
>  drivers/net/bonding/bond_3ad.h   |    2 +-
>  drivers/net/bonding/bond_alb.c   |    6 +-
>  drivers/net/bonding/bond_alb.h   |    2 +-
>  drivers/net/bonding/bond_main.c  |  147 ++++++++++++++++++++-----------------
>  drivers/net/bonding/bond_sysfs.c |   63 +++++-----------
>  drivers/net/bonding/bonding.h    |   13 ++--
>  7 files changed, 117 insertions(+), 122 deletions(-)

applied patches 1-6

However, two issues:

1) Credit.  Did Andy write these, as the Signed-off-by lines indicate? 
If so, you should reflect that with a

	From: Andy Gospodarek <andy@greyhouse.net>

as the first line of your email body.  Linus's git tool will 
automatically notice this special first-line header, and appropriately 
credit the right person.


2) vague subject line.  _Every_ subject line is copied verbatim into the 
kernel changelog, preserved as a permanent one-line summary of the 
changeset.  As such, with considered in the context of the entire kernel,

	Convert more locks to _bh, acquire rtnl, for new locking

tells us nothing at all about the portion of the kernel being modified.

In the future, make sure to include "bonding" somewhere in the subject 
line.  Generally a "bonding: " prefix would probably be best, but it can 
fall elsewhere as your patch #1 subject line indicates.

I hand-edited these subject lines to add "bonding: " prefix before I 
applied the patchset.


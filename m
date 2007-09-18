From: David Miller <davem@davemloft.net>
Subject: Re: [FIX NETLINK] properly check arguments to netlink_bind()
Date: Tue, 18 Sep 2007 14:53:31 -0700 (PDT)
Message-ID: <20070918.145331.67883847.davem@davemloft.net>
References: <87fy1belij.fsf@kruemel.my-eitzenberger.de>
	<876427elan.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: holger@my-eitzenberger.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752045AbXIRVxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 17:53:46 -0400
In-Reply-To: <876427elan.fsf@kruemel.my-eitzenberger.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Holger Eitzenberger <holger@my-eitzenberger.de>
Date: Tue, 18 Sep 2007 23:05:52 +0200

> Holger Eitzenberger <holger@my-eitzenberger.de> writes:
> 
> > while going through going netlink code I found out that netlink_bind()
> > does not properly check bind parameters.  I checked both 2.6.23-rc1 as
> > well as 2.6.16.53, both are affected.
> >
> > With a small test prog I wasn't able to crash my maschine though, but
> > data was accessed out of bounds.
> 
> See my attached patch, thanks.

Your patch is incorrect and also unnecessary.

Firstly, you patch compares the address _pointer_ against
the minimum length.  That's obviously wrong.

And if you check the call sites of the protocol ->bind() methods, they
all use on-stack buffer for the address object which is at least
MAX_SOCK_ADDR bytes in length so that the bind methods don't have to
check the size if they don't want to.

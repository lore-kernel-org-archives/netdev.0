From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: ifIndex allocation
Date: Tue, 16 May 2006 09:38:30 -0700
Message-ID: <20060516093830.5e755993@localhost.localdomain>
References: <86r72uh53e.fsf@deprecated.bitebene.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18627 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932121AbWEPQid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 12:38:33 -0400
To: "Sven Schnelle" <svens@gmx.de>
In-Reply-To: <86r72uh53e.fsf@deprecated.bitebene.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 May 2006 08:11:01 +0200
"Sven Schnelle" <svens@gmx.de> wrote:

> Hi List,

Redirecting to netdev

> 
> investigating a problem with an snmp software for linux, i was wondering
> why the kernel allocates a new ifindex Number, even if the old one is still
> available. For example, if i unload a network driver module, and reload
> it, it has a different ifindex.

Because when you reload the driver it is effectively a completely new
object.  ifindex is a basically and object id. Ifindices act as soft
references so user space can know about a particular network device
even if name changes or other operations happen.  The reference is soft
because the device can disappear. If the application wants to know about
device removal it can catch the netlink event.


> Looking at the function dev_new_index (line 2620 in net/core/dev.c)
> there is a line 'static int ifindex'. Is there any special reason why
> this variable is static, and the list is not traversed from the
> beginning, so that the first free ifindex will be used?
> 
> 
> Best regards,
> 
> Sven.

It is static because no other code should be looking at it.
It doesn't retraverse from the start because it doesn't want to reuse
an earlier index and confuse an application with a soft reference.

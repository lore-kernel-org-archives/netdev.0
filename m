From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [INET] Fix netdev renaming and inet address labels
Date: Fri, 04 Jan 2008 00:57:04 -0800 (PST)
Message-ID: <20080104.005704.267427157.davem@davemloft.net>
References: <1199375823-28729-1-git-send-email-markmc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46830
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754632AbYADI5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:57:05 -0500
In-Reply-To: <1199375823-28729-1-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Thu,  3 Jan 2008 15:57:03 +0000

> When re-naming an interface, the previous secondary address
> labels get lost e.g.
> 
>   $> brctl addbr foo
>   $> ip addr add 192.168.0.1 dev foo
>   $> ip addr add 192.168.0.2 dev foo label foo:00
>   $> ip addr show dev foo | grep inet
>     inet 192.168.0.1/32 scope global foo
>     inet 192.168.0.2/32 scope global foo:00
>   $> ip link set foo name bar
>   $> ip addr show dev bar | grep inet
>     inet 192.168.0.1/32 scope global bar
>     inet 192.168.0.2/32 scope global bar:2
> 
> Turns out to be a simple thinko in inetdev_changename() - clearly we
> want to look at the address label, rather than the device name, for
> a suffix to retain.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>

This bug has been there since the function in question was
written :-)

Patch applied, thanks Mark.

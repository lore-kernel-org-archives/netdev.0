From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 18:06:00 -0700
Message-ID: <m1ljisid8n.fsf@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<20091030.124153.00934819.davem@davemloft.net>
	<21200.1256937150@death.nxdomain.ibm.com>
	<m1639wo5gb.fsf@fess.ebiederm.org>
	<32609.1256947853@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59639 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757578AbZJaBF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 21:05:59 -0400
In-Reply-To: <32609.1256947853@death.nxdomain.ibm.com> (Jay Vosburgh's message of "Fri\, 30 Oct 2009 17\:10\:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> writes:

> 	No, to both questions.  Also, if I back out the 7 bonding
> patches, the same insmod / rmmod does not panic.  
>
> 	I just set it up and did it again.  Fresh boot of the system
> (which doesn't load bonding); "insmod drivers/net/bonding/bonding.ko;
> rmmod bonding" and blammo.
>
> 	A little bisect action reveals that the problem first appears
> after applying the fifth patch (below).  Does a basic insmod / rmmod
> cycle work ok for you?  I'm specifying no options to bonding.

It works here.  The only issue I found was that veth wasn't quite
working.   I am wondering if there was some version of the tree
where rtnl_link_unregister is broken and you applied the patches to that.

I tested the net-next tree with my patches at the top:

There are some other differences like I am running a 64bit kernel but
I don't expect that would make a difference in practice.

Eric

commit 6639104bd826e0b1388c69a6b7564fffc636c8a8
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Oct 29 23:58:54 2009 +0000

    bond: Get the rtnl_link_ops support correct
    
    - Don't call rtnl_link_unregister if rtnl_link_register fails
    - Set .priv_size so we aren't stomping on uninitialized memory
      when we use netdev_priv, on bond devices created with
      ip link add type bond.
    
    Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


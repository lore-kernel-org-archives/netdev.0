From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Marking struct pernet_operations __net_initdata
 was inappropriate
Date: Fri, 26 Oct 2007 22:55:16 -0700 (PDT)
Message-ID: <20071026.225516.152502425.davem@davemloft.net>
References: <4721D283.4050909@bull.net>
	<20071026.045503.62376243.davem@davemloft.net>
	<m1hckdwici.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751542AbXJ0FzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 01:55:14 -0400
In-Reply-To: <m1hckdwici.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 26 Oct 2007 17:45:33 -0600

> 
> It is not safe to to place struct pernet_operations in a special section.
> We need struct pernet_operations to last until we call unregister_pernet_subsys.
> Which doesn't happen until module unload.
> 
> So marking struct pernet_operations is a disaster for modules in two ways.
> - We discard it before we call the exit method it points to.
> - Because I keep struct pernet_operations on a linked list discarding
>   it for compiled in code removes elements in the middle of a linked
>   list and does horrible things for linked insert.
> 
> So this looks safe assuming __exit_refok is not discarded
> for modules.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks Eric.

Although juding by his comments I though that Denis had different
plans in mind to fix this.

From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 04/05: sch_htb: move hash and sibling list removal
	to htb_delete
Date: Wed, 2 Jul 2008 23:14:02 +0200
Message-ID: <20080702211402.GA2476@ami.dom.local>
References: <20080702081559.GA2764@ami.dom.local> <486B543A.8040608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:20245 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbYGBVPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 17:15:03 -0400
Received: by ug-out-1314.google.com with SMTP id h2so603074ugf.16
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2008 14:15:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <486B543A.8040608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A tiny update below...

On Wed, Jul 02, 2008 at 12:11:06PM +0200, Patrick McHardy wrote:
...
> commit c5b52f74c6b35a570995472295a5dae9d3d3ca74
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Jul 2 12:10:36 2008 +0200
> 
>     net-sched: sch_htb: move hash and sibling list removal to htb_delete
>     
>     Hash list removal currently happens twice (once in htb_delete, once
>     in htb_destroy_class), which makes it harder to use the dynamically
>     sized class hash without adding special cases for HTB. The reason is

-     that qdisc destruction destroys class in hierarchical order, which
+     that qdisc destruction destroys classes in hierarchical order, which
-     is not necessary if filters are destroyed in a seperate iteration
+     is not necessary if filters are destroyed in a separate iteration

>     during qdisc destruction.
>     
>     Adjust qdisc destruction to follow the same scheme as other hierarchical
>     qdiscs by first performing a filter destruction pass, then destroying
>     all classes in hash order.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

I still think the patch is OK, but this one little compile warning
(which, I guess, you've seen already...):

net/sched/sch_htb.c: In function 'htb_destroy_class':
net/sched/sch_htb.c:1215: warning: unused variable 'q'

Jarek P.

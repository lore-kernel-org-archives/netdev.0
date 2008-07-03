From: Patrick McHardy <kaber@trash.net>
Subject: Re: net-sched 00/06: dynamically sized class hashes v2
Date: Thu, 03 Jul 2008 18:09:32 +0200
Message-ID: <486CF9BC.9090202@trash.net>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain> <20080703161403.GA2637@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41753 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbYGCQUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 12:20:47 -0400
In-Reply-To: <20080703161403.GA2637@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Jul 03, 2008 at 05:16:01PM +0200, Patrick McHardy wrote:
> ...
>   
>> The patches need the two filter destruction fixes that went into
>> net-2.6.git to apply cleanly, so they won't apply until net-2.6.git
>> is merged into net-next-2.6.git.
>>     
>
> Patrick, I just was about to write that some patches (1, 3, 5) give
> checkpatch warnings... (but no big deal).
>   

Yeah, for reference:

+struct Qdisc_class_common
+{

ERROR: open brace '{' following struct go on the same line

This is for consistency within the file.
---
WARNING: line over 80 characters
#68: FILE: include/net/sch_generic.h:207:
+extern void qdisc_class_hash_insert(struct Qdisc_class_hash *, struct 
Qdisc_class_common *);
+extern void qdisc_class_hash_remove(struct Qdisc_class_hash *, struct 
Qdisc_class_common *);

Header file, better grep output.
---
WARNING: line over 80 characters
#37: FILE: net/sched/sch_cbq.c:146:
+       struct Qdisc_class_hash clhash;                 /* Hash table of 
all classes */

Basically every line in that struct is over 80 characters
---
WARNING: line over 80 characters
#93: FILE: net/sched/sch_cbq.c:1081:
+                               printk(KERN_WARNING "CBQ: class %08x has 
bad quantum==%ld, repaired.\n", cl->common.classid, cl->quantum);

Already was longer .. I could have fixed this one though.
----
WARNING: line over 80 characters
#105: FILE: net/sched/sch_htb.c:431:
+                               p->un.inner.last_ptr_id[prio] = 
cl->common.classid;

One character overrun I think, but easier to read this way.
---
>
> I'll try to look at this later, but let's say: if I don't write
> means I'm OK with all these patches.
>
Thanks for the review so far.

> BTW: I wonder why cbq and htb have "common", while hfsc "cl_common"?

Consistency, HFSC uses cl_ as prefix for many (unfortunately
not all) class members.


From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Fri, 22 Oct 2010 16:30:52 -0400
Message-ID: <4CC1F47C.9020104@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net> <1287612353.2545.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao103.cox.net ([68.230.240.9]:42538 "EHLO
	eastrmmtao103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab0JVUbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 16:31:00 -0400
In-Reply-To: <1287612353.2545.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Could you provide a disassembly of function fib_rules_lookup ?

Try looking in http://68.100.141.95:3000/linux-crash/.  There should be
the source file I am using (not current release if you recall), the .o,
the disassembly, and a -S compile that makes deducing the line numbers a
little easier.

I have tried adding a recursive spinlock as a quick fix without much
success.  It looks like the code in net/core/fib_rules.c results in some
rather complex code paths through the kernel involving softirq handlers.
 I get lockups though I took steps to make sure local interrupts were
off and preemption disabled when taking the spinlock.

I do not know the RCU API or the network code at all but some of the
code in fib_rules.c does not look right prima facie.  For example,
dump_rules does not seem to bother about RCU when traversing rules_list.
 Its caller, fib_nl_dumprule does, but only for one of two calls.  The
fib_nl_newrule and fib_nl_delrule functions traverse rules_list without
any obvious RCU precautions.

Joe Buehler


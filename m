From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Mon, 01 Mar 2010 11:03:24 +0800
Message-ID: <1267412604.23196.53.camel@debian>
References: <1267067593.16986.1583.camel@debian>
	 <1267097080.2822.14.camel@edumazet-laptop>
	 <1267151683.16986.1646.camel@debian>
	 <1267189945.2822.1572.camel@edumazet-laptop>
	 <1267409827.23196.44.camel@debian>
	 <1267410585.9082.115.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53952 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753891Ab0CADBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 22:01:47 -0500
In-Reply-To: <1267410585.9082.115.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-01 at 10:29 +0800, Eric Dumazet wrote:
> You focus on the case you Intel guys discovered the flaw, using
> loopback interface. I am concerned with a DOS situation, when some bad
> guys on your LAN sends a flood on your machine, using a real 10Gb NIC.
> I was concerned by two things :
> 
> - One process being stuck forever in the __release_sock(), basically
> stopping an application from performing progress. This is a DOS
> problem.
> Our kernel is potentially affected. We probably should do something to
> avoid this problem. But I am _not_ saying this should be done by your
> patch, it is probably possible to address it in an independant patch.

Agreed. Unless you or someone else provides a better idea solves them
both, I'd only fix one problem at a time.

> - One process being stuck in __release_sock() and not yield to other
> processes. This is not the case since we call the
> cond_resched_sofirq()
> function that permits other high priority task to get the CPU.
> 
> 
> One more point :
> 
> If you remember my previous mail, I suggested cleaning the len field
> in
> __release_sock(). This way, you can provide a first patch, protocol
> agnostic, then provide further patch for UDP V4, another patch for UDP
> V6, etc... to have a clean path and make the resolution of the bugs
> more
> self explaining and not as a whole and big patch.

This is my original plan. But davem just mentioned we have to prevent
from maliciously send frames, that means all protocols using backlog.
That makes me consider if I should put the check to the generic path.

Thanks,
-yi


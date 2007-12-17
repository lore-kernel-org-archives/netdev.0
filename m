From: Ludovico Gardenghi <garden@cs.unibo.it>
Subject: Re: [PATCH 0/1] IPN: Inter Process Networking
Date: Mon, 17 Dec 2007 11:47:06 +0100
Message-ID: <20071217104706.GA10966@ripieno.somiere.org>
References: <20071217092401.GC4356@cs.unibo.it> <Pine.LNX.4.64.0712170327410.4467@asgard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Renzo Davoli <renzo@cs.unibo.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from host253-196-149-62.serverdedicati.aruba.it ([62.149.196.253]:35456
	"EHLO styx.acheronte.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934784AbXLQKyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 05:54:15 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712170327410.4467@asgard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 03:31:48AM -0800, david@lang.hm wrote:

> wouldn't it be better to just add the ability for multiple writers to send 
> to the same pipe, and then have all of them splice into the output of that 
> pipe? this would give the same data-agnostic communication that you are 
> looking for, and with the minor detail that software would have to filter 
> out messages that they send, would appear to meet all the goals you are 
> looking at, useing existing kernel features that are designed to be very 
> high performance.

Being able to define both filtering policies (think of a virtual
ethernet layer 2 switch, for instance. We have situations where dozens
or hundreds of virtual cables are connected to the same switch, it would
be much, much slower if you had to awake all the user processes for each
single non-broadcast ethernet frame, and send them useless data) and
delivery guarantees (lossless vs best-effort delivery) are not minor
details in our opinion.

We might have added a level2 virtual ethernet switch at kernel
level, but it seemed to specific. With a minor effort we have split the
"dumb" bus (IPN) and the ability to process specific structured data
with specific policies (sub-modules as kvde_switch).

We surely may adapt existing features (AF_UNIX, or pipes) but they offer
a quite established interface and semantics and we think it should be
better to add a new family. This would prevent from breaking what
already exists and leaving more freedom in defining the new family
according to needs.

As for ptrace vs utrace: ptrace has been designed for debugging; trying
to bend it to be fit for virtualization is likely to end up in an
intricated interface and implementation. utrace has been designed in a
much more general way. You can implement ptrace over utrace, but you can
use utrace also for virtualization in a cleaner, simpler and more
efficient way. Why not?

Ludovico
-- 
<garden@acheronte.it>        #acheronte (irc.freenode.net) ICQ: 64483080
GPG ID: 07F89BB8          Jabber: gardengl@gmail.com Yahoo: gardenghelle
-- This is signature nr. 3556

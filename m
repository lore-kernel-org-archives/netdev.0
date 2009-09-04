From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Fri, 04 Sep 2009 03:36:59 +0200
Message-ID: <4AA06F3B.2050500@trash.net>
References: <4A9FD2DC.7070807@trash.net>	<Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>	<4AA00351.4090601@trash.net> <20090903.163101.154177782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, cl@linux-foundation.org, eric.dumazet@gmail.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51929 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbZIDBhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 21:37:00 -0400
In-Reply-To: <20090903.163101.154177782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 03 Sep 2009 19:56:33 +0200
>
>   
>> It would probably also be possible to use TC classifiers for queue
>> selection.
>>     
>
> You mean just like Intel's multiqueue scheduler and multiqueue
> classifiers which we already have in the tree :-

No, actually integrated in the current infrastructure :) The patches
add a virtual root qdisc, so we still have a single root from userspace's
POV. This qdisc is only used for sch_api purposes and doesn't necessarily
match the real root qdiscs. When a "mq" qdisc is attached (done by
default for multiqueue devices), the queues are exposed as child
classes of this qdisc and can be individually grafted with different
qdiscs.

Since the virtual root is global per device, what we could do is allow
to attach classifiers and execute them in dev_pick_tx() to select the
queue. But currently this would require global locking, so this would
have to be fixed previously. Probably not an easy thing to do.


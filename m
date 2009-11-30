From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 21:15:00 +0100
Message-ID: <4B1427C4.3090509@trash.net>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <m1r5rf4xm9.fsf@fess.ebiederm.org> <4B141EFB.4070409@candelatech.com> <20091130200430.GS14610@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58860 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbZK3UPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:15:00 -0500
In-Reply-To: <20091130200430.GS14610@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise wrote:
> On Mon, Nov 30, 2009 at 11:37:31AM -0800, Ben Greear wrote:
>> This doesn't work if you want to have one application manage lots of 
>> interfaces and send traffic between these interfaces.  Certainly there are 
>> use-cases that can use multiple name-spaces, but it's nice to have the 
>> option not to use them as well.
> 
> Actually, it's quite doable from within one application.  An application 
> I recently adapted to make use of multiple network namespaces within a single 
> process by way of pthreads and unshare(CLONE_NEWNET).  The scheme I used 
> is to just open the socket in a new namespace in a thread.  Since the 
> file descriptor table is still shared, it's easy to send/receive data from 
> any other thread, regardless of which virtual network namespace it's in.  
> All told, setting up virtual routers with namespaces is pretty easy.

Yes, that works for creating sockets. Its gets more complicated
though if you want to change network configuration of those devices
once created and moved to a different namespace. Besides that you
might have to replicate your other configuration, like iptables rules,
routing rules and routes, xfrm policies etc.

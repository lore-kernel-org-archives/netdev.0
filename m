From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 15:04:30 -0500
Message-ID: <20091130200430.GS14610@kvack.org>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <m1r5rf4xm9.fsf@fess.ebiederm.org> <4B141EFB.4070409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35596 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbZK3UE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 15:04:26 -0500
Content-Disposition: inline
In-Reply-To: <4B141EFB.4070409@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 11:37:31AM -0800, Ben Greear wrote:
> This doesn't work if you want to have one application manage lots of 
> interfaces and send traffic between these interfaces.  Certainly there are 
> use-cases that can use multiple name-spaces, but it's nice to have the 
> option not to use them as well.

Actually, it's quite doable from within one application.  An application 
I recently adapted to make use of multiple network namespaces within a single 
process by way of pthreads and unshare(CLONE_NEWNET).  The scheme I used 
is to just open the socket in a new namespace in a thread.  Since the 
file descriptor table is still shared, it's easy to send/receive data from 
any other thread, regardless of which virtual network namespace it's in.  
All told, setting up virtual routers with namespaces is pretty easy.

		-ben


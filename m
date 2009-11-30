From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 15:23:28 -0500
Message-ID: <20091130202328.GU14610@kvack.org>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <m1r5rf4xm9.fsf@fess.ebiederm.org> <4B141EFB.4070409@candelatech.com> <20091130200430.GS14610@kvack.org> <4B1427ED.6070808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57100 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274AbZK3UXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 15:23:22 -0500
Content-Disposition: inline
In-Reply-To: <4B1427ED.6070808@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 12:15:41PM -0800, Ben Greear wrote:
> That still sounds more complicated than the proposed routing table changes,

True.  I agree that being able to accept self-addressed packets via a 
sysctl can be useful.

> at least for my application.  Since I also want to gather stats, set/watch 
> routes,
> etc, on each network device, would I have to keep a thread and netlink 
> socket
> running in each name-space in order to see the various devices?

Yes.  My l2tp daemon is still single threaded internally, so it uses an 
rpc through the threads to open UDP, netlink and L2TP sockets, then manages 
everything from the main event loop.  The thread has to be kept around to 
keep the namespace's task id alive in case one wants to move anything in/out 
of the namespace.

		-ben

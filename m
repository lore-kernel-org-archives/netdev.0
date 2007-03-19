From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: 20 Mar 2007 00:42:48 +0100
Message-ID: <20070319234248.GA93348@muc.de>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <45FEE010.1050103@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colin.muc.de ([193.149.48.1]:1999 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964785AbXCSXmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 19:42:50 -0400
Date: Tue, 20 Mar 2007 00:42:48 +0100
Content-Disposition: inline
In-Reply-To: <45FEE010.1050103@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Possibly not, but I'd like to be able to say with confidence that
> running a PARAVIRT kernel on bare hardware has no performance loss
> compared to running a !PARAVIRT kernel.  There's the case of small
> instruction sequences which have been replaced with calls (such as
> sti/cli/push;popf/etc), 

My guess is that most critical pushf/popf are in spin_lock_irqsave(). It would 
be possible to special case that one -- inline it -- and use out of line
versions for all the others.

-Andi

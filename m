From: Dan Williams <dcbw@redhat.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 12:03:11 -0500
Message-ID: <1363626191.6437.2.camel@dcbw.foobar.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
	 <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
	 <1363290495.1643.29.camel@dcbw.foobar.com>
	 <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9739 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241Ab3CRRCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 13:02:20 -0400
In-Reply-To: <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 09:51 -0700, Lorenzo Colitti wrote:
> On Thu, Mar 14, 2013 at 12:48 PM, Dan Williams <dcbw@redhat.com> wrote:
> > The kernel does not (and shouldn't) trigger anything on carrier change as that's a
> > site-specific/user-specific policy.
> 
> Actually, it *does* trigger events on carrier change: it creates the
> addresses when you connect. It just doesn't delete them when you
> disconnect. So you can get addresses without a userspace daemon, but
> you can never delete them without a userspace daemon.
> 
> I tried to argue that that's incorrect, but, well, the archives show
> how far I got.

It does handle them when you connect, but only if you've set accept_ra
to something > 0.  And something has to set that :)  But in reality,
it's not a problem to listen for new addresses.  But *deleting*
addresses is way out of the kernel's responsibility, because a carrier
event doesn't tell the kernel anything about whether it's reconnecting
to the same network or a different one and thus it doesn't know whether
it should delete the old address or keep it around.  And that's where
the userspace stuff and policy comes in, and the kernel doesn't do
policy.

Dan

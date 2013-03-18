From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 11:39:02 -0700
Message-ID: <CAKD1Yr37t2RJm-fmz=mVYcYWerM5Bu1O1cJMLEqSh=ogvxMrGg@mail.gmail.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
 <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
 <1363290495.1643.29.camel@dcbw.foobar.com> <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
 <20130318183407.GA2740@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Lorenzo Colitti <lorenzo@google.com>,
	Dan Williams <dcbw@redhat.com>,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:63875 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab3CRSjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:39:22 -0400
Received: by mail-oa0-f47.google.com with SMTP id o17so6078925oag.34
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 11:39:22 -0700 (PDT)
In-Reply-To: <20130318183407.GA2740@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 11:34 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> Actually, it *does* trigger events on carrier change: it creates the
>> addresses when you connect. It just doesn't delete them when you
>> disconnect. So you can get addresses without a userspace daemon, but
>> you can never delete them without a userspace daemon.
>
> Not directly related, but I wonder if we should treat the change of the
> mac address as a carrier change in ipv6 to create a new ll address. I
> did not find any satisfying answer yet.

Yes, we should - because if we're attaching to a new link, there might
be someone with a duplicate IPv6 address on it, so we'd need to
perform DAD.

I think the kernel does do this though. So in effect, every new link
you attach to gives you new IPv6 addresses, and never deletes them.
The old ones usually don't work on the new link, so you end up with
broken connectivity. Current solutions are either disable IPv6 or
start a userspace daemon to clean up the non-working addresses.

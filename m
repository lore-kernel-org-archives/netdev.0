From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] core: Don't attempt to load the "" driver.
Date: Wed, 3 Sep 2014 11:18:11 -0700
Message-ID: <20140903111811.2717fb59@urahara>
References: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
	<CAHA+R7P8=pkYfSoqhkiAkLc03V38_WCbqJdLxQKF_Y6YXNnbeg@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1748630E@AcuExch.aculab.com>
	<CAHA+R7OoBp=ZAJeg_hXRjNhT6_n2siVQidJK6hx8EtHW7iRwqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:45376 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbaICSST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 14:18:19 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so18083161pad.21
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 11:18:19 -0700 (PDT)
In-Reply-To: <CAHA+R7OoBp=ZAJeg_hXRjNhT6_n2siVQidJK6hx8EtHW7iRwqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Sep 2014 10:02:26 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Wed, Sep 3, 2014 at 2:02 AM, David Laight <David.Laight@aculab.com> wrote:
> >> On Tue, Sep 2, 2014 at 6:48 AM, David Laight <David.Laight@aculab.com> wrote:
> >> > While the applications shouldn't be calling an SIOCxxx ioctl with ifr_name[0] == 0
> >> > the kernel shouldn't be tracing the error either.
> >> >
> >>
> >> Why don't we reject this empty string? It doesn't look like a valid one.
> >> I assume this is for compatibility?
> >
> > The ioctl code will error it later on - the module load is 'speculative'.
> > Analysing whether all the ioctls need dev_load() to succeed is another issue.
> >
> > Indeed I'm not sure anything stops the module being unloaded before the
> > ioctl action tries to take a real reference on the interface.
> >
> > Whether request_module("") should be an error is a different question,
> > probably much harder to analyse.
> >
> 
> If an empty string is an invalid name, we definitely should reject it from
> the very beginning, so that you would not need to worry about the above
> issues.
> 
> Something like the attached patch.

This will break for many things where the code randomly tries
to load something based on name, but the module is already there.

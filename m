From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2: ip netns: Do not delete netns if there any process use
 it
Date: Wed, 11 Mar 2015 18:50:11 +0200
Message-ID: <20150311165011.GA917@angus-think.lan>
References: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
 <CAHA+R7Pwfjg4642i1FMG1mKJN58K+nYhqvN_NnrbQ+uiPXibGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35818 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbbCKRBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:01:48 -0400
Received: by lams18 with SMTP id s18so10265839lam.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:01:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7Pwfjg4642i1FMG1mKJN58K+nYhqvN_NnrbQ+uiPXibGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 09:38:04AM -0700, Cong Wang wrote:
> On Wed, Mar 11, 2015 at 12:40 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> >
> > Hi,
> >
> > There might be case when it is possible to loose device which was
> > moved to netns if there is process which is running is that netns:
> >
> >     $ ip netns add net
> >     $ ip link set dev eth0 netns net0
> >     $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> >     $ ip netns del net0
> >
> > so eth0 will not appear in the default netns until SOME_PROCESS_IN_BACKGROUND will exit or
> > will ne killed. So to avoid such case it might be better to do not
> > delete netns if there are process in it ? I meant add such validation
> > for 'ip netns del' command.
> 
> No, kernel does all the reference counting, no need to bother iproute2.

Sure kernel does and after net0 file was deleted the devices will be
still alive within net0 till all processes within net0 will exit or will
be killed. And there might be case that after deleting net0 it might be
hard to find these processes and kill them to bring back devices from
net0 to the initial netns.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Fri, 24 May 2013 14:57:01 -0700
Message-ID: <1369432621.3301.445.camel@edumazet-glaptop>
References: <cover.1369406826.git.tgraf@suug.ch>
	 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
	 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
	 <1369421900.3301.431.camel@edumazet-glaptop>
	 <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45885 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab3EXV5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 17:57:03 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so4723031pad.8
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 14:57:02 -0700 (PDT)
In-Reply-To: <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 14:23 -0700, Jesse Gross wrote:
> On Fri, May 24, 2013 at 11:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Fri, 2013-05-24 at 10:24 -0700, Jesse Gross wrote:
> >
> >> Does this have any impact on small packets? Those are usually the
> >> common case (i.e. TCP SYN) and I think this is slightly less optimal
> >> for those.
> >
> > No difference at all, small packets are copied anyway in skb->head
> 
> Yes, but it makes the Open vSwitch code slightly worse - for example,
> currently checksumming and copying are done in a single step but this
> prevents that. Actually, I'm also curious about the test case that was
> used for large packets and the full profile output since checksumming
> and GSO aren't listed in the one that Thomas gave.
> 

GSO is fully supported in nfnetlink, I see no reason why Open vSwitch
would not allow that.

> My guess is that there isn't a real different for small packets since
> everything will be in the cache but it seems worth checking given that
> this is optimizing a rare case at the expense of the common one.

I really doubt checksumming a SYN/ACK packet is that a performance
issue. Do you have performance numbers ?

You could always provide a patch to restore this copy/checksum if it
really gives a benefit, and if people still use NIC not doing this
checksum.

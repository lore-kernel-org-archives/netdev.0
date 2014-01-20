From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 0/2] sctp: some small clean ups
Date: Mon, 20 Jan 2014 07:20:55 -0500
Message-ID: <20140120122055.GA22690@hmsreliant.think-freely.org>
References: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
 <52DD0A62.9050807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Weidong <wangweidong1@huawei.com>, davem@davemloft.net,
	vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaATMVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 07:21:12 -0500
Content-Disposition: inline
In-Reply-To: <52DD0A62.9050807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 20, 2014 at 12:37:06PM +0100, Daniel Borkmann wrote:
> On 01/20/2014 12:27 PM, Wang Weidong wrote:
> >We have the macros in sctp.h, so use them for coding accordance
> >in sctp.
> 
> Thanks for doing this Wang.
> 
> I am actually wondering why we have these macro locking wrappers
> and not use these functions directly? Hm, any reasons? Maybe we
> should rather go in the other direction with this?
> 
Its because in the origional implementation of the sctp protocol, there was a
user space test harness which built the kernel module for userspace execution to
cary our some unit testing on the code.  It did so by redefining some of those
locking macros to user space friendly code.  IIRC we haven't use those unit
tests in years, and so should be removing them, not adding them to other
locations.

Neil

> >Wang Weidong (2):
> >   sctp: use sctp_local_bh_{disable|enable} instead
> >     local_bh_{disable|enable}
> >   sctp: use sctp_read_[un]lock instead of read_[un]lock
> >
> >  net/sctp/endpointola.c   |  4 ++--
> >  net/sctp/input.c         | 10 +++++-----
> >  net/sctp/proc.c          | 12 ++++++------
> >  net/sctp/sm_make_chunk.c |  8 ++++----
> >  net/sctp/socket.c        |  8 ++++----
> >  5 files changed, 21 insertions(+), 21 deletions(-)
> >
> 

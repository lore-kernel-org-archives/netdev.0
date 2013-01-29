From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] pktgen: support net namespace
Date: Tue, 29 Jan 2013 11:02:43 +0800
Message-ID: <1359428563.20729.12.camel@cr0>
References: <1359424389-21919-1-git-send-email-amwang@redhat.com>
	 <874ni0k965.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845Ab3A2DCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 22:02:52 -0500
In-Reply-To: <874ni0k965.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-28 at 18:36 -0800, Eric W. Biederman wrote:
> Cong Wang <amwang@redhat.com> writes:
> 
> > From: Cong Wang <amwang@redhat.com>
> >
> > v2: remove a useless check
> >
> > This patch add net namespace to pktgen, so that
> > we can use pktgen in different namespaces.
> >
> > Cc: Eric W. Biederman <ebiederm@xmission.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> >
> > ---
> >  net/core/pktgen.c |  123 +++++++++++++++++++++++++++++++++++------------------
> >  1 files changed, 81 insertions(+), 42 deletions(-)
> 
> Skiming through this again I have spotted what looks like a pretty
> major bug.  You are limiting yourself to one network device per network
> namespace when the actual limit is one network device per thread.
> 
> I think you can just kill the dev member of pktgen_net and the two or
> three lines of code that touch it.

Good point!

It is used by pktgen_device_event() to check if the device generates the
event is the one in our namespace.

It is safe to continue the search even if it is not in our namespace,
but it is not efficient. Probably we need to make pktgen_threads list
per-namespace.

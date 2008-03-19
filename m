From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Wed, 19 Mar 2008 14:20:10 -0700
Message-ID: <20080319142010.ed564c39.akpm@linux-foundation.org>
References: <20080318015006.3f0efb8e.akpm@linux-foundation.org>
	<20080318210542.GA2764@ami.dom.local>
	<20080318144742.83f544f9.akpm@linux-foundation.org>
	<20080318224729.GA2760@ami.dom.local>
	<20080319191724.GA2756@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37540 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765606AbYCSVUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:20:20 -0400
In-Reply-To: <20080319191724.GA2756@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Mar 2008 20:17:25 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Tue, Mar 18, 2008 at 11:47:29PM +0100, Jarek Poplawski wrote:
> ...
> > Anyway... My first tests seemed to hang the box with syslog only. Now
> > I can't repeat it neither with syslog nor netconsole... So, this patch
> > is a bad hit or it's really about timing.
> 
> I've just repeated this this test with syslog only. After letting it
> go for ~5 min. I couldn't break it with any keys for at least next 10
> min., and I turned the power down. Then the same but with this sched.c
> patch reverted: ^C worked after a few seconds. It looks like time
> can really matter here.

Yeah, I was fiddling with that.  If you do

for i in $(seq 100)
do
	echo t > /proc/sysrq-trigger
done

then yes there's no response to ^C and the machine is basically dead.  But
when the loop finishes, things return to normal.

Perhaps it's something to do with longer holds on tasklist_lock, something
liek that.

> So, maybe it's again something accidental, I don't have another box
> around to stay idle while repeting this test, but it seems this could
> be not the best way to compare anything with 2.6.24 or older.

No.  I still haven't retested on the other offending machine.  Right now
I'm not sure that we any longer have anything which needs fixing.  Apart
from merging netpoll-zap_completion_queue-adjust-skb-users-counter.patch?

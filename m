From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-mm1 thread exit_group issue
Date: Sat, 13 Oct 2007 10:49:43 -0700
Message-ID: <20071013104943.e4a54abe.akpm@linux-foundation.org>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org>
	<20071012140328.f82af8e8.kamezawa.hiroyu@jp.fujitsu.com>
	<20071011234202.2f15bb76.akpm@linux-foundation.org>
	<20071012064658.GA8181@ftp.linux.org.uk>
	<20071012001325.ba02a6f0.akpm@linux-foundation.org>
	<20071012194759.GA31733@Krystal>
	<20071012180349.b4b4c2c3.akpm@linux-foundation.org>
	<20071013114820.GA121@tv-sign.ru>
	<20071013120230.GA130@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	viro@ftp.linux.org.uk, kamezawa.hiroyu@jp.fujitsu.com,
	linux-kernel@vger.kernel.org, sam@ravnborg.org,
	netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
	Sukadev Bhattiprolu <sukadev@us.ibm.com>,
	Paul Menage <menage@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47137 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754258AbXJMRwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 13:52:00 -0400
In-Reply-To: <20071013120230.GA130@tv-sign.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Oct 2007 16:02:30 +0400 Oleg Nesterov <oleg@tv-sign.ru> wrote:

> On 10/13, Oleg Nesterov wrote:
> >
> > On 10/12, Andrew Morton wrote:
> > >
> > > Bisection shows that this problem is caused by these two patches:
> > >
> > > pid-namespaces-allow-cloning-of-new-namespace.patch
> > 
> > This? http://marc.info/?l=linux-mm-commits&m=118712242002039
> > 
> > Pavel, this patch has a subtle difference compared to what we discussed on
> > containers list. It moves put_user(parent_tidptr) from copy_process() to
> > do_fork(), so we don't report child's pid if copy_process() failed. I do
> > not think this is bad, but Eric seems to disagree with such a change.
> > 
> > But I can't understand why Andrew sees the same problem _after_ this patch!
> >
> > And which patch removed the "put_user(nr, parent_tidptr)" chunk?
> 
> Aha. I am looking at
> 	ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23/2.6.23-mm1/broken-out/pid-namespaces-allow-cloning-of-new-namespace.patch
> 
> Looks like the original patch was damaged somehow, it doesn't have the
> "put_user(nr, parent_tidptr)" code.
> 

It does have it, except it moved somewhere else.  That would have been me
trying to fix yet another reject storm.  I thought I had that one right. 
Could someone fix it please?


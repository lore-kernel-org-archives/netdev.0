From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 26 Jun 2007 09:24:08 -0600
Message-ID: <m17ipqu4br.fsf@ebiederm.dsl.xmission.com>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
	<20070607.184731.10907840.davem@davemloft.net>
	<E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu>
	<m17ipxfi9d.fsf@ebiederm.dsl.xmission.com>
	<E1I21IL-0004LH-00@dorka.pomaz.szeredi.hu>
	<m1ir9eaahu.fsf@ebiederm.dsl.xmission.com>
	<E1I36oi-0002bb-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38078 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138AbXFZPY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 11:24:57 -0400
In-Reply-To: <E1I36oi-0002bb-00@dorka.pomaz.szeredi.hu> (Miklos Szeredi's
	message of "Tue, 26 Jun 2007 10:54:32 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Miklos Szeredi <miklos@szeredi.hu> writes:
>
> And I think incremental GC algorithms are much too complex for this
> task.  What I've realized, is that in fact we don't require a generic
> garbage collection algorithm, just a much more specialized cycle
> collection algorithm, since refcounting in struct file takes care of
> the rest.
>
> This would help with localizing the problem to the problematic sockets
> (which have an in-flight unix socket), instead of having to blindly
> traverse _all_ unix sockets in the system.
>
> I'll look at reimplementing the GC with such an algorithm.

Ok.  If you can do it more simply have at it.

There are incremental garbage collectors that are essentially just the
current algorithm with fine-grained locking.  So we don't have to live
in a spin-lock the whole time.

If your approach fails we can look at something more fine-grained.

>> It appears clear that since we can't stop the world and garbage
>> collect we need an incremental collector.
>
> Constraining ourselves to stopping unix sockets from going in flight
> or coming out of flight during garbage collection should be OK I
> think.  There's still a possibility of a DoS there, but it would only
> be able to affect _very_ few applications.

Yes.

Eric

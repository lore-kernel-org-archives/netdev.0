From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 28 Oct 2015 07:47:57 -0700
Message-ID: <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <20151024023054.GZ22011@ZenIV.linux.org.uk>
	 <201510270908.t9R9873a001683@room101.nl.oracle.com>
	 <562F577E.6000901@oracle.com> <20151027231702.GA22011@ZenIV.linux.org.uk>
	 <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
	 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35254 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbJ1Or7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 10:47:59 -0400
In-Reply-To: <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-28 at 06:24 -0700, Eric Dumazet wrote:

> Before I take a deep look at your suggestion, are you sure plain use of
> include/linux/percpu-refcount.h infra is not possible for struct cred ?

BTW, I am not convinced we need to spend so much energy and per-cpu
memory for struct cred refcount.

The big problem is fd array spinlock of course and bitmap search for
POSIX compliance.

The cache line trashing in struct cred is a minor one ;)

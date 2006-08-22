From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] kevent_user: remove non-chardev interface
Date: Tue, 22 Aug 2006 13:27:31 +0100
Message-ID: <20060822122731.GA2994@infradead.org>
References: <12345678912345.GA1898@2ka.mipt.ru> <11561555871530@2ka.mipt.ru> <20060822115459.GA10839@infradead.org> <20060822121709.GA4815@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39078 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751221AbWHVM1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 08:27:54 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060822121709.GA4815@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 04:17:10PM +0400, Evgeniy Polyakov wrote:
> I personally do not have objections against it, but it introduces
> additional complexies - one needs to open /dev/kevent and then perform
> syscalls on top of returuned file descriptor.

it disalllows

int fd = sys_kevent_ctl(<random>, KEVENT_CTL_INIT, <random>, <random>);

in favour of only

int fd = open("/dev/kevent", O_SOMETHING);

which doesn't seem like a problem, especially as I really badly hope
no one will use the syscalls but some library instead.

In addition to that I'm researching whether there's a better way to
implement the other functionality instead of the two syscalls.  But I'd
rather let code speak, so wait for some patches from me on that.


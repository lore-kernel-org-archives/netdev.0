From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Kevent POSIX timers support.
Date: Tue, 28 Nov 2006 22:22:36 +0300
Message-ID: <20061128192236.GA2051@2ka.mipt.ru>
References: <456B3016.9020706@redhat.com> <20061127.104955.48519839.davem@davemloft.net> <20061128091602.GC15083@2ka.mipt.ru> <20061128.111300.105813754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org,
	chase.venters@clientec.com, johann.borck@densedata.com,
	linux-kernel@vger.kernel.org, jeff@garzik.org, aviro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:13473 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S936047AbWK1TXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 14:23:21 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061128.111300.105813754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 28, 2006 at 11:13:00AM -0800, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 28 Nov 2006 12:16:02 +0300
> 
> > Although ukevent has pointer embedded, it is unioned with u64, so there
> > should be no problems until 128 bit arch appeared, which likely will not
> > happen soon. There is also unused in kevent posix timers patch
> > 'u32 ret_val[2]' field, which can store segval's value too.
> > 
> > But the fact that ukevent does not and will not in any way have variable
> > size is absolutely.
> 
> I believe that in order to be %100 safe you will need to use the
> special aligned_u64 type, as that takes care of a crucial difference
> between x86 and x86_64 API, namely that u64 needs 8-byte alignment on
> x86_64 but not on x86.
> 
> You probably know this already :-)

Yep :)
So I put it at the end, where structure is already correctly aligned, so
there is no need for special alignment.
And, btw, last time I checked, aligned_u64 was not exported to
userspace.

-- 
	Evgeniy Polyakov

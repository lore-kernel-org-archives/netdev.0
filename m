From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take34 0/10] kevent: Generic event handling mechanism.
Date: Fri, 26 Jan 2007 01:56:34 +0300
Message-ID: <20070125225634.GA9905@2ka.mipt.ru>
References: <1315adqaa0591036@2ka.mipt.ru> <11697329102169@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11697329102169@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 25, 2007 at 04:48:30PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Changes from 'take33' patchset:
>  * Added optional header pointer and its size into aio_sendfile_path(), 
>    which allows to send header and file in one syscall instead of
>    send(header), open file, sendfile(file).

Btw, aio_sendfile and aio_sendfile_path use naive and actually the 
simplest approach of async IO - it just stupidly blocks on sending or 
resends (like repeated sending approach) - I'm a bit lazy to use kevent 
there, since there is _no_ gain after a bit more deep analysis 
(hint: there are multiple IO threads, some of them might block), 
and network AIO does not exist (yet, kevent status is in hinged state,
and I was asked to postpone additional feature addons, which otherwise
could happen a bit more frequently then current kevent/kernel releases), 
due to kevent future is indeterminate...

-- 
	Evgeniy Polyakov

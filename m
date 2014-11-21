From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Fri, 21 Nov 2014 19:39:11 +0000
Message-ID: <20141121193911.GU7996@ZenIV.linux.org.uk>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
 <20141119.161744.1661940121298888832.davem@davemloft.net>
 <20141119213006.GE7996@ZenIV.linux.org.uk>
 <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141120222506.GS7996@ZenIV.linux.org.uk>
 <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141121084956.GT7996@ZenIV.linux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6D1C9F6930@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F6930@AcuExch.aculab.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2014 at 05:42:55PM +0000, David Laight wrote:

> Callers of kernel_send/recvmsg() could easily be using a wrapper
> function that creates the 'msghdr'.
> When the want to send the remaining part of a buffer the old iterator
> will no longer be available - just the original iov and the required offset.

Er...  So why not copy a struct iov_iter to/from msg->msg_iter, then?
It's not as it had been particulary large - 5 words isn't much...

I'm not at all sure that _anything_ has valid reasons for draining iovecs.
Maintaining a struct iov_iter and modifying it is easy and actually faster...

Right now the main examples outside of net/* are due to unfortunate
limitations of ->sendmsg() - until now it had no way to be told that
desired data starts at offset.  With ->msg_iter it obviously becomes
possible...

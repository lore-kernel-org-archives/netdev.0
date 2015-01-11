From: Christoph Jaeger <cj@linux.com>
Subject: Re: [PATCH net] packet: bail out of packet_snd() if L2 header
 creation fails
Date: Sun, 11 Jan 2015 14:34:04 -0500
Message-ID: <20150111193404.GN1513@betelgeuse.hsd1.ma.comcast.net>
References: <1420999276-28225-1-git-send-email-cj@linux.com>
 <1421002345.9233.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan <alan@linux.intel.com>, davem@davemloft.net,
	willemb@google.com, edumazet@google.com, dborkman@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421002345.9233.1.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 11, 2015 at 10:52:25AM -0800, Joe Perches wrote:
> On Sun, 2015-01-11 at 13:01 -0500, Christoph Jaeger wrote:
> > Due to a misplaced parenthesis, the expression
> > 
> >   (unlikely(offset) < 0),
> > 
> > which expands to
> > 
> >   (__builtin_expect(!!(offset), 0) < 0),
> 
> Here's another one:
> 
> drivers/platform/goldfish/goldfish_pipe.c:285:	if (unlikely(bufflen) == 0)

Well, the conditional statement works as intended. Of course, the branch
prediction doesn't.

Coccinelle should be able to check for this kind of likely()/unlikely() usage,
shouldn't it?

~Christoph

From: Jens Axboe <axboe@suse.de>
Subject: Re: async network I/O, event channels, etc
Date: Thu, 27 Jul 2006 10:29:24 +0200
Message-ID: <20060727082924.GK5282@suse.de>
References: <20060727.010255.87351515.davem@davemloft.net> <20060727080901.GG5282@suse.de> <20060727081114.GH5282@suse.de> <20060727.012037.78156999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932359AbWG0I3e@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.012037.78156999.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27 2006, David Miller wrote:
> From: Jens Axboe <axboe@suse.de>
> Date: Thu, 27 Jul 2006 10:11:15 +0200
> 
> > Ownership transition from user -> kernel that is, what I'm trying to say
> > that returning ownership to the user again is the tricky part.
> 
> Yes, it is important that for TCP, for example, we don't give
> the user the event until the data is acknowledged and the skb's
> referencing that data are fully freed.
> 
> This is further complicated by the fact that packetization boundaries
> are going to be different from AIO buffer boundaries.
> 
> I think this is what you are alluding to.

Precisely. And this is the bit that is currently still broken for
splice-to-socket, since it gives that ack right after ->sendpage() has
been called. But that's a known deficiency right now, I think Alexey is
currently looking at that (as well as receive side support).

-- 
Jens Axboe

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: design for TSO performance fix
Date: Fri, 28 Jan 2005 11:30:28 -0800
Message-ID: <20050128113028.55a41603.davem@davemloft.net>
References: <20050127163146.33b01e95.davem@davemloft.net>
	<m1zmyu2hot.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmyu2hot.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 07:25:54 +0100
Andi Kleen <ak@muc.de> wrote:

> Currently tcp_sendmsg will always push the first packet when the send_head
> is empty way down to hard_queue_xmit, and then queue up some others
> and then finally push them out. You would always miss the first
> one with that right? (assuming MTU sized packets)

We could make push_pending_frames defer if we're doing TSO
and might potentially be building suck frames.

It's just a detail, the main idea is what counts which is
to keep all the TSO packets out of the view of most of the
stack which is where all the complexity came from.

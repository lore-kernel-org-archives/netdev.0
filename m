From: "David S. Miller" <davem@redhat.com>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 16:08:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215160810.5cea9216.davem@redhat.com>
References: <3FDE13AE.3050402@candelatech.com>
	<20031215141729.15387fc1.davem@redhat.com>
	<3FDE39E3.4000408@candelatech.com>
	<20031215145422.58a78551.davem@redhat.com>
	<3FDE4109.7090603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FDE4109.7090603@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003 15:17:29 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Well, I was assuming that the stats polling is a fixed cost O(1),
> where-as the per-packet calculation is O(n).  I am quite sure this
> assumption is true for e1000, but I have not looked at tg3.  So, for
> e1000, the cost of subtracting out the FCS would be basically free.

I see, I misunderstood your idea.  That would work, and yes all of
the effort would be expended at netdev->get_stats() time.

> All that said, from Randy's email, it appears we should be including
> the FCS anyway...

Yes, indeed.  So the drivers that do not have hardware statistics
doing this, and are using skb->len, need to add on the FCS length
(which is 4 bytes right?) when accumulating stats->* values.

Sounds like a nice janitor job :)

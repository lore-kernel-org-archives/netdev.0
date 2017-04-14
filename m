From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Fri, 14 Apr 2017 11:05:25 +0200
Message-ID: <20170414110525.41317f5a@redhat.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <20170413042036.GA46229@ast-mbp.thefacebook.com>
        <20170413.113722.2174945057832588335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751693AbdDNJFb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Apr 2017 05:05:31 -0400
In-Reply-To: <20170413.113722.2174945057832588335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Apr 2017 11:37:22 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Wed, 12 Apr 2017 21:20:38 -0700
> 
> > On Wed, Apr 12, 2017 at 02:54:15PM -0400, David Miller wrote:  
[...]
> 
> If the capability is variable, it must be communicated to the user
> somehow at program load time.
> 
> We are consistently finding that there is this real need to
> communicate XDP capabilities, or somehow verify that the needs
> of an XDP program can be satisfied by a given implementation.

I fully agree that we need some way to express capabilities[1]

[1] http://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/design.html#capabilities-negotiation

> Maximum headroom is just one.

[...]
> 
> We can only optimize this and elide things when we have a facility in
> the future for the program to express it's needs precisely.  I think
> we will have to add some control structure to XDP programs that can
> be filled in for this purpose.

I fully agree that we need some control structure to XDP programs.  My
previous attempt was shot-down due to performance concerns of an extra
pointer dereference. As I explained before, this is not a concern as
the dereference will happen once per N packets in the NAPI loop.

Plus now we see a need to elide things based on facilities the XDP
program choose to use/enable, for performance reasons.  I would prefer
keeping these facility settings in control structure to XDP programs,
instead of pulling in derived bits runtime.   Again remember, adding
if/branch statements checking for facilities, should have little
performance impact as the branch predictor should guess correctly given
we process N packets in the NAPI loop with same facilities.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

From: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
Subject: Re: [PATCH] tcp: efficient port randomisation
Date: Mon, 1 Nov 2004 11:58:23 +0200
Message-ID: <200411011058.23141.michael.vittrup.larsen@ericsson.com>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net> <200410291048.01955.michael.vittrup.larsen@ericsson.com> <20041029102828.123502e7@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041029102828.123502e7@zqx3.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 29 October 2004 19:28, Stephen Hemminger wrote:
> Provide port randomization for incoming connections using variation of
> existing sequence number hash. Replace tcp_portalloc_lock and
> tcp_port_rover with atomic operation to allow better parallelism.
>
> This is based on
> http://www.ietf.org/internet-drafts/draft-larsen-tsvwg-port-randomisation-0
>0.txt (with confirmation of of no IPR issues).

I have looked through this, and have a few comments:

* It is probably a good strategy to set 'tcp_rover_next' such that
  the next search is resumed from the previous port found to be free.
  (similar to the old algorithm).  I don't see this in your patch,
  but of course I could have missed it.

* connect_port_offset() does not (at least from an algorithm point
  of view) need to return an u32, an u16 is sufficient.


Michael Larsen

From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bridge] Re: [PATCH] (6/6) bridge: receive path optimization
Date: Thu, 26 May 2005 15:48:57 -0700
Message-ID: <20050526154857.3cb34d11@dxpl.pdx.osdl.net>
References: <20050526110425.27590eb8@dxpl.pdx.osdl.net>
	<20050526.144638.71091166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050526.144638.71091166.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 May 2005 14:46:38 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Thu, 26 May 2005 11:04:25 -0700
> 
> > This improves the bridge local receive path by avoiding going
> > through another softirq.  The bridge receive path is already being called 
> > from a netif_receive_skb() there is no point in going through another
> > receiveq round trip. 
> > 
> > Recursion is limited because bridge can never be a port of a bridge
> > so handle_bridge() always returns.
> 
> I applied all 6 patches, but this one in particular I'd like
> to comment on.
> 
> Remember all of those bridge netfilter stack usage issues
> we have a few months ago?  This could edge us back into
> those problems again.

no, because the br_frame_finish is called after the netfilter
decision:
	netif_receive_skb
	   handle_bridge
               br_handle_frame 
		  br_handle_frame_finish
		     br_pass_frame_up
			br_pass_frame_up_finish
			   netif_receive_skb  <---- change
				(normal receive path)

So the call chain is bounded (ie not related to number of filters)
but slightly longer.

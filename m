From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v3] openvswitch: Fix egress tunnel info.
Date: Sat, 24 Oct 2015 12:26:04 +0200
Message-ID: <20151024122604.45453ac9@griffin>
References: <1445563036-9623-1-git-send-email-pshelar@nicira.com>
	<20151023141738.4db54324@griffin>
	<CALnjE+oOrvGmXuW0aexHt_CO2W7DEMLJyHzW3psCFuK+aG+5Yg@mail.gmail.com>
	<20151023202207.1533982b@griffin>
	<CALnjE+p644A-H1Kj3cc2WE_NOwyeU-8A_8bfvjp_ykUxcUmWeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbbJXK0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2015 06:26:08 -0400
In-Reply-To: <CALnjE+p644A-H1Kj3cc2WE_NOwyeU-8A_8bfvjp_ykUxcUmWeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Oct 2015 12:47:09 -0700, Pravin Shelar wrote:
> This is not complete code. I found couple of issues with it.

That's likely, I didn't test it :-)

> This code does not copy lwtunnel_state state into new dst.

Not sure what state you mean. All the relevant state should be in
struct ip_tunnel_info.

> And it is converting lwtunnel dst into metadata dst.

I did that intentionally. But your comment made me realize that I was
too much focused on the tunnel implementation side. This function,
should it be used outside of ovs, could be called earlier than the skb
is handed to the tunnel. Then we of course need a valid dst->output and
this approach (converting lwtunnel data to metadata_dst) would fail.
This is the same problem we have with IPv6 ndisc replies.

This needs more thinking and is out of scope of what you're trying to
solve. Sorry for the noise. But at least it made me realize that the
ndisc problem (that I still don't have a good solution for) is broader.

Thanks,

 Jiri

-- 
Jiri Benc

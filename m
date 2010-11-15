From: Eric Paris <eparis@redhat.com>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Mon, 15 Nov 2010 10:47:46 -0500
Message-ID: <1289836066.14282.7.camel@localhost.localdomain>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
	 <00c201cb81eb$84e18160$8ea48420$@com> <4CDCEE65.3060105@trash.net>
	 <017301cb82bf$54540cf0$fcfc26d0$@com>  <4CE10C2A.1050801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hua Zhong <hzhong@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CE10C2A.1050801@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-11-15 at 11:32 +0100, Patrick McHardy wrote:
> On 13.11.2010 00:14, Hua Zhong wrote:
> >> On 11.11.2010 22:58, Hua Zhong wrote:
> >>>> Yes, I realize this is little different than if the
> >>>> SYN was dropped in the first network device, but it is different
> >>>> because we know what happened!  We know that connect() call failed
> >>>> and that there isn't anything coming back.
> >>>
> >>> I would argue that -j DROP should behave exactly as the packet is
> >> dropped in the network, while -j REJECT should signal the failure to
> >> the application as soon as possible (which it doesn't seem to do).
> >>
> >> It sends an ICMP error or TCP reset. Interpretation is up to TCP.
> > 
> > Huh? It's the OUTPUT chain we are talking about. There is no ICMP error or
> > TCP reset.
> 
> Of course there is.
> 
> ICMP (default):
> 
> iptables -A OUTPUT -p tcp -j REJECT
> 
> TCP reset:
> 
> iptables -A OUTPUT -p tcp -j REJECT --reject-with tcp-reset
> 
> The second one will cause a hard error for the connection.

Well I'm (I guess?) surprised that the --reject-with icmp doesn't do
anything with a local outgoing connection but --reject-with tcp-reset
does something like what I'm looking for.

I notice the heavy lifting for this is done in 
net/ipv4/netfilter/ipt_REJECT.c::send_rest()
(and something very similar for IPv6)

I really don't want to duplicate that code into SELinux (for obvious
reasons) and I'm wondering if anyone has objections to me making it
available outside of netlink and/or suggestions on how to make that code
available outside of netfilter (aka what header to expose it, and does
it still make logical sense in ipt_REJECT.c or somewhere else?)

-Eric

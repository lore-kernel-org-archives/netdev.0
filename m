From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.35 5/6] lib: Push MPLS tags in the OpenFlow
 1.3 ordering
Date: Wed, 7 Aug 2013 09:17:40 -0700
Message-ID: <20130807161740.GE2293@nicira.com>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
	<1374289623-17056-6-git-send-email-horms@verge.net.au>
	<CAOftzPjviFrD5c3ZHM6n6-Ud+REyiuaXgNzea7TFNrYZADqdXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOftzPjviFrD5c3ZHM6n6-Ud+REyiuaXgNzea7TFNrYZADqdXQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 06, 2013 at 11:04:31AM +0900, Joe Stringer wrote:
> The general background to this patch is that we aim to keep the datapath
> interface for MPLS actions simple. As such, when pushing an MPLS tag, this
> is done immediately after the ethernet header regardless of the presence of
> VLANs (As per OF1.3 spec). We can then implement OF1.2 behaviour by popping
> any existing VLAN tags before applying MPLS actions, then pushing the tags
> back on afterwards. This is all done on the odp actions translation side.

I think that keeping the interface simple is a good approach.  Always
pushing labels just after the Ethernet header sounds reasonable to me.
(I don't speak for Jesse.  He might have a different idea.)

> I'm wondering if this general approach is the preferred method, and as an
> extension, what are your thoughts on how these patches add the new
> 'vlan_tci' field into 'struct xlate_in' and apply VLAN actions twice
> (before and/or after MPLS actions). This provides a mechanism to support
> both OF1.2 and OF1.3 behaviours within the scope of current VLAN support,
> but may or may not fit in well with future ideas for QinQ (ie,
> double-stacked 0x8100 tags) or 802.1ad support.

In general, if userspace code works for our current needs, and kernel
code works for our current needs and can be extended to foreseeable
future needs, then that's fine.  I often find it to be a mistake to try
to generalize too much in advance.

Thanks,

Ben.

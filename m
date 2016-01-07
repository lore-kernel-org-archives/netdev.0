From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Thu, 7 Jan 2016 18:21:37 +0100
Message-ID: <20160107172137.GA24672@pox.localdomain>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <20160106.155950.1007160228570301281.davem@davemloft.net>
 <8660z6qohn.fsf@weave.works>
 <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
 <568DADEE.1050206@stressinduktion.org>
 <CAEh+42h_dH5-AYBN+L=+LMfNLXhSfs-AwWh_aZ_oLfZ1NV48Zg@mail.gmail.com>
 <20160107114935.GJ32456@pox.localdomain>
 <CAEh+42hA69_e1HRGzsfzc2yGNgr6d8Bg4+pD8EQPdou5LzUegA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Wragg <david@weave.works>,
	David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36466 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcAGRVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:21:40 -0500
Received: by mail-wm0-f46.google.com with SMTP id l65so105767967wmf.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 09:21:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAEh+42hA69_e1HRGzsfzc2yGNgr6d8Bg4+pD8EQPdou5LzUegA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/16 at 08:35am, Jesse Gross wrote:
> On Thu, Jan 7, 2016 at 3:49 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > A simple start could be to add a new return code for > MTU drops in
> > the dev_queue_xmit() path and check for NET_XMIT_DROP_MTU in
> > ovs_vport_send() and emit proper ICMPs.
> 
> That could be interesting. The problem in the past was making sure
> that ICMPs that are generated fit in the virtual network appropriately
> - right addresses, etc. This requires either spoofing addresses or
> some additional knowledge about the topology that we don't currently
> have in the kernel.

Are you worried about emitting an ICMP with a source which is not
a local host address?

Can't we just use icmp_send() in the context of the inner header and
feed it to the flow table to send it back? It should be the same as
for ip_forward().

skb->dev or skb->dst should lead us to the real MTU which can be
included in the ICMP frag needed. It's a bit tricky because we would
have to know whether it was encapsulated or not and adjust
accordingly.

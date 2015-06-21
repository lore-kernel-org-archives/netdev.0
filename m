From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Sun, 21 Jun 2015 22:40:44 +0200
Message-ID: <20150621204044.GD4228@pox.localdomain>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
 <55842A93.2040607@brocade.com>
 <558431C3.5020703@cumulusnetworks.com>
 <5584507C.2000303@brocade.com>
 <5584609C.5020802@cumulusnetworks.com>
 <558461CB.3020408@brocade.com>
 <5585784D.3020809@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Shearman <rshearma@brocade.com>, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34453 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbbFUUkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 16:40:47 -0400
Received: by wicnd19 with SMTP id nd19so59679731wic.1
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 13:40:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5585784D.3020809@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/15 at 07:27am, roopa wrote:
> On 6/19/15, 11:39 AM, Robert Shearman wrote:
> >On 19/06/15 19:34, roopa wrote:
> >>On 6/19/15, 10:25 AM, Robert Shearman wrote:
> >>>n 19/06/15 16:14, roopa wrote:
> >>>
> >>In the netdevice case, this output function is not called atall. It
> >>should just follow the existing netdevice the route is pointing to.
> >
> >Sorry for not being clear, but I meant that there would have to be
> >lwtunnel_skb_lwstate functions for ipv4 and ipv6 to match the output
> >functions. So in the vxlan use case where it's using a netdevice, how
> >would it determine which one to call?
> 
> thanks for that clarification, and good point. I see some areas of the
> kernel checking for skb->protocol to do the conversion (something like
> below). I am guessing that is acceptable.
> if (skb->protocol == htons(ETH_P_IPV6))
>                 struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);

I'm not yet convinced that it makes sense to offer the no-netdevice
shortcut for VXLAN. I'm not convinced we need yet another VXLAN data
path. In fact, I'm trying to get rid of the OVS one for this specific
reason.

I have no objection though if somebody comes up with an architecture
that can't just pass the required metadata between the namespaces and
do the actual encapsulation in a single net_device in the root/host
namespace.

Either way, I thin it's fair to defer to this to a later point. We
don't need to solve this for the first iteration of MPLS and VXLAN
implementation.

From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Sun, 21 Jun 2015 19:48:49 -0700
Message-ID: <55877791.1030500@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <55842A93.2040607@brocade.com> <558431C3.5020703@cumulusnetworks.com> <5584507C.2000303@brocade.com> <5584609C.5020802@cumulusnetworks.com> <558461CB.3020408@brocade.com> <5585784D.3020809@cumulusnetworks.com> <20150621204044.GD4228@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Shearman <rshearma@brocade.com>, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35979 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbbFVCsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 22:48:51 -0400
Received: by paceq1 with SMTP id eq1so99326387pac.3
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 19:48:51 -0700 (PDT)
In-Reply-To: <20150621204044.GD4228@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/15, 1:40 PM, Thomas Graf wrote:
> On 06/20/15 at 07:27am, roopa wrote:
>> On 6/19/15, 11:39 AM, Robert Shearman wrote:
>>>
>>> Sorry for not being clear, but I meant that there would have to be
>>> lwtunnel_skb_lwstate functions for ipv4 and ipv6 to match the output
>>> functions. So in the vxlan use case where it's using a netdevice, how
>>> would it determine which one to call?
>> thanks for that clarification, and good point. I see some areas of the
>> kernel checking for skb->protocol to do the conversion (something like
>> below). I am guessing that is acceptable.
>> if (skb->protocol == htons(ETH_P_IPV6))
>>                  struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
> I'm not yet convinced that it makes sense to offer the no-netdevice
> shortcut for VXLAN. I'm not convinced we need yet another VXLAN data
> path. In fact, I'm trying to get rid of the OVS one for this specific
> reason.
>
> I have no objection though if somebody comes up with an architecture
> that can't just pass the required metadata between the namespaces and
> do the actual encapsulation in a single net_device in the root/host
> namespace.
>
> Either way, I thin it's fair to defer to this to a later point. We
> don't need to solve this for the first iteration of MPLS and VXLAN
> implementation.
ack, thanks for your thoughts on this.

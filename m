From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Sat, 20 Jun 2015 07:27:25 -0700
Message-ID: <5585784D.3020809@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <55842A93.2040607@brocade.com> <558431C3.5020703@cumulusnetworks.com> <5584507C.2000303@brocade.com> <5584609C.5020802@cumulusnetworks.com> <558461CB.3020408@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35373 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754925AbbFTO11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 10:27:27 -0400
Received: by pdbci14 with SMTP id ci14so50732391pdb.2
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 07:27:26 -0700 (PDT)
In-Reply-To: <558461CB.3020408@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 11:39 AM, Robert Shearman wrote:
> On 19/06/15 19:34, roopa wrote:
>> On 6/19/15, 10:25 AM, Robert Shearman wrote:
>>> n 19/06/15 16:14, roopa wrote:
>>>
>> In the netdevice case, this output function is not called atall. It
>> should just follow the existing netdevice the route is pointing to.
>
> Sorry for not being clear, but I meant that there would have to be 
> lwtunnel_skb_lwstate functions for ipv4 and ipv6 to match the output 
> functions. So in the vxlan use case where it's using a netdevice, how 
> would it determine which one to call?

thanks for that clarification, and good point. I see some areas of the 
kernel checking for skb->protocol to do the conversion (something like 
below). I am guessing that is acceptable.
if (skb->protocol == htons(ETH_P_IPV6))
                 struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);

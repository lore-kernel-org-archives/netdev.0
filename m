From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Fri, 12 Jun 2015 09:15:53 -0700
Message-ID: <557B05B9.6030003@cumulusnetworks.com>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com> <20150605091441.GA11896@pox.localdomain> <5571AF28.8000009@cumulusnetworks.com> <5571BF90.2070304@brocade.com> <557260E0.9060500@cumulusnetworks.com> <20150608123302.GA3634@pox.localdomain> <5575B207.4040900@cumulusnetworks.com> <20150608225843.GA4602@pox.localdomain> <5577E387.4030206@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Shearman <rshearma@brocade.com>, ebiederm@xmission.com,
	netdev@vger.kernel.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:33180 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264AbbFLQP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 12:15:56 -0400
Received: by qgfa66 with SMTP id a66so12992760qgf.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:15:56 -0700 (PDT)
In-Reply-To: <5577E387.4030206@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/15, 12:13 AM, roopa wrote:
> Robert/Thomas, All my changes are in the below repo under the 'mpls' 
> branch.
> https://github.com/CumulusNetworks/net-next
> https://github.com/CumulusNetworks/iproute2
>
> The last iproute2 commit has a sample usage.
>
> The commits pushed to this tree do not contain support for the 
> following yet (but working on it):
> a) tunnel routes to work with tunnel RTA_OIF and a non-tunnel RTA_OIF:
> The current commits in the tree assume a non-tunnel RTA_OIF.
> If the tunnel driver has registered a dst_output func,  dst_output
> is set to the tunnel dst output handler in the receive route lookup 
> path which in turn does the encap
> and xmits. Thomas had last suggested using a flag to skip the dst 
> output handler re-direction
> for cases where RTA_OIF is a special tunnel netdev and the tunnel 
> driver xmit function
> can do the encap. My current thinking is to pass the oif to the encap 
> parse handler and the handler can set the flag on the tunnel state. 
> And this flag can then be used to skip the dst_output re-direction.
> This change should be trivial will fix it soon.

I have pushed this change to my github tree.
>
> b) make RTA_OIF optional and do a fib lookup.
>
thinking about this some more, RTA_OIF is already optional. And 
net/ipv4/fib_semantics.c:fib_check_nh will lookup the dev if not 
specified. Wouldn't that be enough ?. (unless i have misunderstood 
something here)

thanks,
Roopa

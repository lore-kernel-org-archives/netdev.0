From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Fri, 05 Jun 2015 19:54:24 -0700
Message-ID: <557260E0.9060500@cumulusnetworks.com>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com> <20150605091441.GA11896@pox.localdomain> <5571AF28.8000009@cumulusnetworks.com> <5571BF90.2070304@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, ebiederm@xmission.com,
	netdev@vger.kernel.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33532 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbFFCy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 22:54:28 -0400
Received: by qkhg32 with SMTP id g32so49855670qkh.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 19:54:27 -0700 (PDT)
In-Reply-To: <5571BF90.2070304@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/15, 8:26 AM, Robert Shearman wrote:
>
> It isn't clear to me what the strategy here is for dealing with tunnel 
> encaps that aren't bound to an interface.
>
> Thomas, I presume you would prefer not to force the user to keep track 
> of changes to the output interface and nexthop corresponding to the 
> destination of the outer IP header? And I presume that Eric is opposed 
> to the option of using a virtual interface here, i.e. falling back to 
> the approach I proposed?
>
> In which case, what will the nexthop output interface be set to? 
> Logically, it should have no interface. At the moment, the code 
> assumes that a nexthop will have a valid interface and I don't have a 
> feel for what the impact would be of changing that.

The nexthop interface is the final output interface. Any reason it 
should not be ?
>
> However, with that resolved I'd be happy to work on a series together. 
> The remaining issue is whether to optimise for small encap that reside 
> in the same memory block as the fib_info, which aren't refcounted but 
> instead are copied around, or larger encaps that reside in their own 
> memory block that are refcounted and only a pointer passed around.
I would prefer the latter (as shown in my incomplete patch) simply 
because it stays separate from fib_info and allows for extending it in 
the future.

> If the latter, then there really isn't much left in my patch series 
> that can be reused, other than references to the places in the code 
> that need to be changed to support multipath and to make fib_info 
> matching work correctly.

Thanks,
Roopa

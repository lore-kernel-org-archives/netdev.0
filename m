From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 16:16:09 -0700
Message-ID: <deb0ea2f-364a-59fe-0bcd-1f46557522f8@cumulusnetworks.com>
References: <54cf1176-5131-c0a0-572e-47feda7e07a9@cumulusnetworks.com>
 <20170117.153846.1832359427601278475.davem@davemloft.net>
 <7655b85f-4c03-7f08-315c-b6a99a1631f0@cumulusnetworks.com>
 <20170117.155424.1815351091063210993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35685 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751759AbdAQXQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:16:11 -0500
Received: by mail-pf0-f170.google.com with SMTP id f144so65367812pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:16:11 -0800 (PST)
In-Reply-To: <20170117.155424.1815351091063210993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/17 1:54 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue, 17 Jan 2017 13:46:22 -0700
> 
>> In short seems like removing the dev + the current patch dropping
>> the lock fixes the current deadlock problem and should be fine.
> 
> What about the state recorded by fib_get_nhs() and similar?  There is
> a mapping from ifindex to ->nh_dev which would be invalidated if the
> RTNL semaphore is dropped.

As far as I can see through the call to build_state all device indices came from the user and have not been validated yet (once the dev arg to build_state is removed; sent that patch for net-next). The device index validation happens later in fib_create_info with the call to fib_check_nh (or dev_get_by_index for host scope).

I sent an alternative approach that pulls the module loading into a separate function that is called while creating the fib_config. Performance heavy for multipath but solves the autoload without delving into the restart problem.

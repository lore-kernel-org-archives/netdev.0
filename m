From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 13:46:22 -0700
Message-ID: <7655b85f-4c03-7f08-315c-b6a99a1631f0@cumulusnetworks.com>
References: <8b621810-f7b3-05bb-413b-29389125c6ea@cumulusnetworks.com>
 <0e226af4-cb62-9b20-f8a2-191b0aaffb11@brocade.com>
 <54cf1176-5131-c0a0-572e-47feda7e07a9@cumulusnetworks.com>
 <20170117.153846.1832359427601278475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36395 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdAQUqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:46:24 -0500
Received: by mail-pf0-f172.google.com with SMTP id 189so64637595pfu.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 12:46:24 -0800 (PST)
In-Reply-To: <20170117.153846.1832359427601278475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/17 1:38 PM, David Miller wrote:
> But, that being said, I don't think we can legitimately just remove the
> autoload functionality.  It's been there for close to a full year and
> I guarantee people will get burned if we take it away.
> 
> We have to find a way to fix this.

I have patch that removes the dev from build_state. Nothing about an encap state should require a device and none of the current encaps use it so it can be removed without a problem. After that the only reference I have noted is to a table and the only table that can be deleted - and invalidating the pointer - is the local table and that only happens once on fib_unmerge.

In short seems like removing the dev + the current patch dropping the lock fixes the current deadlock problem and should be fine.

Robert: do you agree?

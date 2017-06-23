From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] af_iucv: Move sockaddr length checks to
 before accessing sa_family in bind and connect handlers
Date: Fri, 23 Jun 2017 14:53:45 -0400 (EDT)
Message-ID: <20170623.145345.2050178619729566336.davem@davemloft.net>
References: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
        <20170623173228.70128-3-jwi@linux.vnet.ibm.com>
        <90c818a5-af59-3115-64c2-582c2dcc520b@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jwi@linux.vnet.ibm.com, netdev@vger.kernel.org,
        linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35676 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754706AbdFWSxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:53:47 -0400
In-Reply-To: <90c818a5-af59-3115-64c2-582c2dcc520b@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 23 Jun 2017 19:36:12 +0200

> 
> 
> On 06/23/2017 07:32 PM, Julian Wiedmann wrote:
>> From: Mateusz Jurczyk <mjurczyk@google.com>
>> 
>> Verify that the caller-provided sockaddr structure is large enough to
>> contain the sa_family field, before accessing it in bind() and connect()
>> handlers of the AF_IUCV socket. Since neither syscall enforces a minimum
>> size of the corresponding memory region, very short sockaddrs (zero or
>> one byte long) result in operating on uninitialized memory while
>> referencing .sa_family.
> 
> Won't it make sense to generally check the minimum length for .sa_family at a
> single point before fixing all called sites?

We had this discussion last week and we decided that putting it into
the handlers is the way to go for now.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 15:05:27 -0400 (EDT)
Message-ID: <20170411.150527.283014710949232666.davem@davemloft.net>
References: <20170411173143.GA1899@salvia>
        <20170411.134225.398046538225438175.davem@davemloft.net>
        <cb6106f2-3128-da79-69bf-a10b249db054@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, johannes@sipsolutions.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        jhs@mojatatu.com, jbenc@redhat.com, jiri@resnulli.us
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35358 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbdDKTFa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 15:05:30 -0400
In-Reply-To: <cb6106f2-3128-da79-69bf-a10b249db054@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 11 Apr 2017 12:57:59 -0600

> On 4/11/17 11:42 AM, David Miller wrote:
>> David, if you have a specific case where it's absolutely impossible
>> to resolve this when the library is converted to support extended
>> ACKs, please mention it.
> 
> I don't have a specific library in mind. It is more the disjoint nature
> of a socket option and message parsing, and thinking through the API.

Would you prefer it being passed via a control message at sendmsg()
time?  That would require more changes to userland programs, and also
increase the per-request overhead in the kernel as it parses this CMSG
every single time.

We have a setsockopt for AF_PACKET that changes the entire layout of
the packet mmap ring, nobody complains that libraries are hard to
implement because of that right?

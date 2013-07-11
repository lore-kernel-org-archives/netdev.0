From: Wei Liu <liuw@liuw.name>
Subject: Re: [Xen-devel] [PATCH v2 1/1] xen/netback: correctly calculate
 required slots of skb.
Date: Thu, 11 Jul 2013 22:12:30 +0100
Message-ID: <CAOsiSVXkQAZoj=y7iV7PbwmbQE5ZS1FJHmcryvA7FJT1UEXJKg@mail.gmail.com>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com> <20130711.130314.2300492549661006309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ANNIE LI <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matt Wilson <msw@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:56743 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756596Ab3GKVNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 17:13:01 -0400
Received: by mail-wi0-f169.google.com with SMTP id c10so14624wiw.0
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 14:13:00 -0700 (PDT)
In-Reply-To: <20130711.130314.2300492549661006309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 9:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Annie Li <annie.li@oracle.com>
> Date: Wed, 10 Jul 2013 17:15:11 +0800
>
>> When counting required slots for skb, netback directly uses DIV_ROUND_UP to get
>> slots required by header data. This is wrong when offset in the page of header
>> data is not zero, and is also inconsistent with following calculation for
>> required slot in netbk_gop_skb.
>>
>> In netbk_gop_skb, required slots are calculated based on offset and len in page
>> of header data. It is possible that required slots here is larger than the one
>> calculated in earlier netbk_count_requests. This inconsistency directly results
>> in rx_req_cons_peek and xen_netbk_rx_ring_full judgement are wrong.
>>
>> Then it comes to situation the ring is actually full, but netback thinks it is
>> not and continues to create responses. This results in response overlaps request
>> in the ring, then grantcopy gets wrong grant reference and throws out error,
>> for example "(XEN) grant_table.c:1763:d0 Bad grant reference 2949120", the
>> grant reference is invalid value here. Netback returns XEN_NETIF_RSP_ERROR(-1)
>> to netfront when grant copy status is error, then netfront gets rx->status
>> (the status is -1, not really data size now), and throws out error,
>> "kernel: net eth1: rx->offset: 0, size: 4294967295". This issue can be reproduced
>> by doing gzip/gunzip in nfs share with mtu = 9000, the guest would panic after
>> running such test for a while.
>>
>> This patch is based on 3.10-rc7.
>>
>> Signed-off-by: Annie Li <annie.li@oracle.com>
>
> A lot of discussion... will we have another respin of this patch or can I
> get an ACK from Ian or someone else?
>

Matt also proposed a solution to this issue ([PATCH RFC] xen-netback: calculate
the number of slots required for large MTU vifs -- it's posted on netdev as
well).

We're discussing these two patches at the moment and have not come to a
conclusion on which one to go in. I would really appreciate if you could wait a
little longer. Thanks.


Wei.

> Thanks.
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel

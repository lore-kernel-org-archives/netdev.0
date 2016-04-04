From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: socket: return a proper error code when source
 address becomes nonlocal
Date: Mon, 4 Apr 2016 15:55:34 +0300
Message-ID: <57026446.1010801@cogentembedded.com>
References: <1459753769-4290-1-git-send-email-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liping Zhang <liping.zhang@spreadtrum.com>
To: Liping Zhang <zlpnobody@163.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34240 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbcDDMzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 08:55:36 -0400
Received: by mail-lf0-f41.google.com with SMTP id c62so169219094lfc.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 05:55:35 -0700 (PDT)
In-Reply-To: <1459753769-4290-1-git-send-email-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/4/2016 10:09 AM, Liping Zhang wrote:

> From: Liping Zhang <liping.zhang@spreadtrum.com>
>
> 1. Socket can use bind(directly) or connect(indirectly) to bind to a local
>     ip address, and later if the network becomes down, that cause the source
>     address becomes nonlocal, then send() call will fail and return EINVAL.
>     But this error code is confusing, acctually we did not pass any invalid
>     arguments. Furthermore, send() maybe return ok at first, it now returns
>     fail just because of a temporary network problem, i.e. when the network
>     recovery, send() call will become ok. Return EADDRNOTAVAIL instead of
>     EINVAL in such situation is better.
> 2. We can use IPV6_PKTINFO to specify the ipv6 source address when call
>     sendmsg() to send packet, but if the address is not available, call will
>     fail and EINVAL is returned. This error code is not very appropriate,
>     it failed maybe just because of a temporary network problem. Also
>     RFC3542, section 6.6 describe an example returns EADDRNOTAVAIL:
>     "ipi6_ifindex specifies an interface but the address ipi6_addr is not
>     available for use on that interface.". So return EADDRNOTAVAIL instead
>     of EINVAL here.
>
> Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>

    I think this should be 2 patches as you seem to fix 2 separate problems.

[...]

MBR, Sergei

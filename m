From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch net 2/2] mlxsw: pci: Correctly determine if descriptor
 queue is full
Date: Mon, 7 Mar 2016 17:04:59 +0300
Message-ID: <56DD8A8B.8000705@cogentembedded.com>
References: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
 <1457339092-2878-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34232 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcCGOFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 09:05:03 -0500
Received: by mail-lb0-f174.google.com with SMTP id xr8so34500839lbb.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 06:05:02 -0800 (PST)
In-Reply-To: <1457339092-2878-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/7/2016 11:24 AM, Jiri Pirko wrote:

> From: Ido Schimmel <idosch@mellanox.com>
>
> The descriptor queues for sending (SDQs) and receiving (RDQs) packets
> are managed by two counters - producer and consumer - which are both
> 16-bit in size. A queue is considered full when the difference between
> the two equals the queue's maximum number of descriptors.
>
> However, if the producer counter overflows, then it's possible for the
> full queue check to fail, as it doesn't take the overflow into account.
> In such a case, descriptors already passed to the device - but for which
> a completion has yet to be posted - will be overwritten, thereby causing
> undefined behavior. The above can be achieved under heavy load (~30
> netperf instances).
>
> Fix that by casting the substraction result to u16, preventing it from

    Subtraction.

> being treated as a signed integer.
>
> Fixes: eda6500a987a ("mlxsw: Add PCI bus implementation")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

[...]

MBR, Sergei

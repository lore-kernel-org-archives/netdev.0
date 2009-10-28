From: Ben Greear <greearb@candelatech.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 13:04:19 -0700
Message-ID: <4AE8A3C3.1070003@candelatech.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE7F859.7020105@gmail.com> <4AE895E8.60308@trash.net> <4AE89927.9090405@candelatech.com> <4AE8A098.8040207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44489 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbZJ1UET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:04:19 -0400
In-Reply-To: <4AE8A098.8040207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2009 12:50 PM, Patrick McHardy wrote:

>> And, even 1MB may not be enough for some scenarios.  So, probably best to
>> let users over-ride the initial setting on cmd-line.  If not, then use
>> a large value to start with.
>
> How about this? It uses 1MB as receive buf limit by default (without
> increasing /proc/sys/net/core/rmem_max it will be limited by less
> however) and allows to specify the size manually using "-rcvbuf X"
> (-r is already used, so you need to specify at least -rc).
>
> Additionally rtnl_listen() continues on ENOBUFS after printing the
> error message.

Looks good..except:

If rmem_max is smaller than 1M, will that cause setsocktopt to
fail and thus fail early out of rtnl_open_byproto?

Maybe we should only print errors but not return in that method
when setsockopt fails?

In another project, I ended up trying ever smaller values until one
worked in order to get near what the user wanted even if rmem_max
was configured smaller.  Not sure if that is worth doing here or not.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


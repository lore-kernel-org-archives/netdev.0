From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Tue, 7 Jun 2016 19:06:15 -0400
Message-ID: <57575367.4010604@akamai.com>
References: <20160602002354.GG1644@akamai.com> <20160606223106.GA1621@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:50503 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752599AbcFGXGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:06:16 -0400
In-Reply-To: <20160606223106.GA1621@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2016 06:31 PM, Pablo Neira Ayuso wrote:
> On Wed, Jun 01, 2016 at 08:23:54PM -0400, Vishwanath Pai wrote:
>> netfilter/nflog: nflog-range does not truncate packets
>>
>> The --nflog-range parameter from userspace is ignored in the kernel and
>> the entire packet is sent to the userspace. The per-instance parameter
>> copy_range still works, with this change --nflog-range will have
>> preference over copy_range.
> 
> I think it's reasonable to assume that --nflog-range from the rule
> applies globally to any instance.
> 
> However, per-instance copy_range has prevailed over --nflog-range
> since the beginning, so I would follow a more conservative approach,
> ie. remain copy_range in preference over --nflog-range.
> 
> So I'd suggest you invert this logic.
> 
> Let me know, thanks.
> 

Thanks for reviewing this. I think my comment on the patch was
misleading, we do give preference to copy_range and that is what we
default to. --nflog-range will not override the per-instance default,
the only time it would get preference is when its value is lesser than
the per-instance value. If copy_range is lesser than --nflog-range then
we retain copy_range.

So basically what we are doing is min(copy_range, nflog-range). Just
wanted to clarify this, if this is not how it's meant to be please let
me know.

Also, there is a bug in my patch, li->u.ulog.copy_len can be set to "0"
from userspace (if --nflog-range is not specified), so we have to check
for this condition before using the value. I will send a V2 of the patch
based on your reply.

Thanks,
Vishwanath

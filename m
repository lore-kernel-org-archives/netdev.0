From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: Question with commit 299b0767(ipv6: Fix IPsec slowpath fragmentation
 problem)
Date: Wed, 15 Feb 2012 15:00:04 +0800
Message-ID: <4F3B57F4.10106@cn.fujitsu.com>
References: <4F38C57F.5000706@cn.fujitsu.com> <20120214110414.GA31660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52337 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752951Ab2BOHAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 02:00:00 -0500
In-Reply-To: <20120214110414.GA31660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert wrote:
> On Mon, Feb 13, 2012 at 04:10:39PM +0800, Li Wei wrote:
>> Hi, Steffen!
>>
>> I found some problem while doing networking tests with IPSec that
>> the first fragment doesn't use the max MTU to fill payload, but with
>> 20 bytes smaller. When I reverted your commit 299b0767(ipv6: Fix 
>> IPsec slowpath fragmentation problem), things goes well.
>>
>> Would you so kindly to point me out what the commit did, because I
>> think the original implementation had taken IPSec header and tailer
>> into account.
>>
> 
> Without this patch we used always the slow path in ip6_fragment()
> due to a miscalculation of the packet lenght in ip6_append_data().
> 
> This patch just makes use of the reduced IPsec mtu, and adapts
> the IPsec header handling to have enought headroom on the skb.
> 
> 

Hi Steffen,

Thank you for your reply!

I see in your patch that you use the "mtu" of &rt->dst (which taken IPSec
into account) instead of rt->dst.path, but the "exthdrlen" and "dst_exthdrlen"
things process IPSec again. Does some duplication there?

After reverted the patch and put some "printk" things in the slow_path of
ip6_fragment(), setup IPSec transport mode between two hosts, when sending
some echo request which exceeds the MTU, I don't see any "printk" in slow_path
outputed. Could you tell me how to reproduce the slow_path things?

Thanks,
Wei

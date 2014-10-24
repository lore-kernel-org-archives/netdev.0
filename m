From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [QA-TCP] How to send tcp small packages immediately?
Date: Fri, 24 Oct 2014 08:19:46 -0700
Message-ID: <544A6E12.2000007@hp.com>
References: <544A029D.3080508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>, kvm@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	liuyongan@huawei.com, qinchuanyu@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2354.austin.hp.com ([15.217.128.53]:51870 "EHLO
	g2t2354.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbaJXPTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 11:19:49 -0400
In-Reply-To: <544A029D.3080508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2014 12:41 AM, Zhangjie (HZ) wrote:
> Hi,
>
> I use netperf to test the performance of small tcp package, with TCP_NODELAY set :
>
> netperf -H 129.9.7.164 -l 100 -- -m 512 -D
>
> Among the packages I got by tcpdump, there is not only small packages, also lost of
> big ones (skb->len=65160).
>
> IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 65160
> IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
> IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
> IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
> IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 65160
> IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
> IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
> IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
> IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 80
> IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 512
> IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 512
>
> SO, how to test small tcp packages? Including TCP_NODELAY, What else should be set?

Well, I don't think there is anything else you can set.  Even with 
TCP_NODELAY set, segment size with TCP will still be controlled by 
factors such as congestion window.

I am ass-u-me-ing your packet trace is at the sender.  I suppose if your 
sender were fast enough compared to the path that might combine with 
congestion window to result in the very large segments.

Not to say there cannot be a bug somewhere with TSO overriding 
TCP_NODELAY, but in broad terms, even TCP_NODELAY does not guarantee 
small TCP segments.  That has been something of a bane on my attempts to 
use TCP for aggregate small-packet performance measurements via netperf 
for quite some time.

And since you seem to have included a virtualization mailing list I 
would also ass-u-me that virtualization is involved somehow.  Knuth only 
knows how that will affect the timing of events, which will be very much 
involved in matters of congestion window and such.  I suppose it is even 
possible that if the packet trace is on a VM receiver that some delays 
in getting the VM running could mean that GRO would end-up making large 
segments being pushed up the stack.

happy benchmarking,

rick jones

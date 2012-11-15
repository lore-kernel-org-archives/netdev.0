From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Thu, 15 Nov 2012 10:31:42 +0800
Message-ID: <50A4540E.1010601@oracle.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com> <1349790863.21172.4406.camel@edumazet-glaptop> <1349792241.21847.199.camel@zakaz.uk.xensource.com> <1349792847.21172.4479.camel@edumazet-glaptop> <1349793630.21847.208.camel@zakaz.uk.xensource.com> <1349863984.10070.26.camel@zakaz.uk.xensource.com> <1349874598.10070.39.camel@zakaz.uk.xensource.com> <748966751.20121010164949@eikelenboom.it> <1349942546.14806.7.camel@zakaz.uk.xensource.com> <151954917.20121011120004@eikelenboom.it> <1349949924.21172.8462.camel@edumazet-glaptop> <1349950494.14806.29.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	xen-devel <xen-devel@lists.xen.org>,
	"Marcos E. Matsunaga" <Marcos.Matsunaga@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29756 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423500Ab2KOCb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 21:31:59 -0500
In-Reply-To: <1349950494.14806.29.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-10-11 18:14, Ian Campbell wrote:
> On Thu, 2012-10-11 at 11:05 +0100, Eric Dumazet wrote:
>> On Thu, 2012-10-11 at 12:00 +0200, Sander Eikelenboom wrote:
>>
>>> Probably due to the BUG_ON from the patch below, i changed it into a WARN_ON.
>>> And i seem to hit it, but only in one of the guests at the moment and it triggers quite irregularly.
>> xennet_make_frags() is able to split the skb->head in multiple page-size
>> chunks.
>>
>> It should do the same for fragments
> Right, I just want to be reproduce the issue so I can know I've fixed it
> properly ;-)
Hi Ian,

I can reproduce this BUG_ON when running netperf/netserver test between 
two domus running on the same dom0. The domu and dom0 all use v3.7-rc1.

When I tried to rebase my persistent grant netfront/netback patch on 
latest kernel, netperf/netserver test never succeeded. I did some test 
to find out that v3.6-rc7 works fine, but v3.7-rc1, v3.7-rc2 and 
v3.7-rc4 does not succeed in netperf/netserver test. So I keep my 
persistent grant patch only based on v3.4-rc3 now.

Konrad thought about commit 6a8ed462f16b8455eec5ae00eb6014159a6721f0 in 
v3.7-rc1, and suggested me to test your debug patch in netfront. This 
BUG_ON happens soon after running the netperf/netserver test case.

Thanks
Annie
>
> Ian.
>
>
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel

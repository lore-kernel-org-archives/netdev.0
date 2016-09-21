From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 21 Sep 2016 18:49:18 +0200
Message-ID: <f0ae4d21-8e72-079a-dfd3-c315f24f0e7c@stressinduktion.org>
References: <20160920185737.GU8920@oracle.com>
 <4617aca3-8d44-e99a-cc5a-1088b30ae327@stressinduktion.org>
 <20160921161457.GA17116@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, jbenc@redhat.com, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46002 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934834AbcIUQtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 12:49:21 -0400
In-Reply-To: <20160921161457.GA17116@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.09.2016 18:14, Alexei Starovoitov wrote:
> On Wed, Sep 21, 2016 at 12:10:55PM +0200, Hannes Frederic Sowa wrote:
>> On 20.09.2016 20:57, Sowmini Varadhan wrote:
>>> The vxlan header may not be aligned to 4 bytes in
>>> vxlan_build_skb (e.g., for MLD packets). This patch
>>> avoids unaligned access traps from vxlan_build_skb
>>> (in platforms like sparc) by making struct vxlanhdr __packed.
>>>
>>> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>>
>> Performance wise this should only affect code generation for archs where
>> it matters anyway.
> 
> I think it's the opposite. Even on x86 compiler will use byte loads.

I checked that on x86-64 actually. Also clearly visible here:

https://godbolt.org/g/xsW2P1

Bye,
Hannes

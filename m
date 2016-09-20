From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 13:07:42 -0400
Message-ID: <20160920170742.GR8920@oracle.com>
References: <20160920142700.GJ8920@oracle.com>
 <20160920181114.0ac7cfa0@griffin>
 <20160920163108.GP8920@oracle.com>
 <20160920184333.17444823@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50648 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755492AbcITRIE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:08:04 -0400
Content-Disposition: inline
In-Reply-To: <20160920184333.17444823@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/20/16 18:43), Jiri Benc wrote:
> 
> IPv6 header is certainly not 20 bytes.

vxlan encapsulates an IPv6/ethernet frame in a UDP/IPv4/ethernet packet.
the ipv4 header is 20 bytes (without options).
mld_newpack is dealing with the vxlan net_device in this case,
which has ->hard_header_len of 14, and ->needed_headroom of 64,
so hlen (used in mld_newpack) comes out to be 80.

> If you see unaligned access, something is wrong. But I very much doubt
> that the problem is at the place you're trying to fix. Could you share
> the traces with us?

Exactly what traces do you want? I think you can check this easily
by using printk's predicated on IS_ALIGNED checks in vxlan_build_skb().
IPv6 MLD triggers this quite easily.

I will try out Hannes' solution (which makes sense) in a moment, 
and report back.

--Sowmini

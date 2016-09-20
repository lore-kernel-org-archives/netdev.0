From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 18:43:33 +0200
Message-ID: <20160920184333.17444823@griffin>
References: <20160920142700.GJ8920@oracle.com>
        <20160920181114.0ac7cfa0@griffin>
        <20160920163108.GP8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38282 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932643AbcITQnh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 12:43:37 -0400
In-Reply-To: <20160920163108.GP8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 12:31:08 -0400, Sowmini Varadhan wrote:
> The vxlan header is after the ethernet header (14 bytes),
> IP header (20 bytes, assuming no options) and udp header (8 bytes).

If the VXLAN header is not aligned to 4 bytes, then IP header is not
aligned to 4 bytes, too, and you have greater problems than just VXLAN.

> Post the skb_reserve adjustments (see computations in in mld_newpack(),
> for example), this triggers an unaligned access on sparc.

IPv6 header is certainly not 20 bytes.

If you see unaligned access, something is wrong. But I very much doubt
that the problem is at the place you're trying to fix. Could you share
the traces with us?

 Jiri

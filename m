From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Fri, 23 Sep 2016 08:06:18 -0400 (EDT)
Message-ID: <20160923.080618.678103827885223586.davem@davemloft.net>
References: <20160920190929.57ddaeb0@griffin>
        <20160922.015242.735026657310158125.davem@davemloft.net>
        <20160922213010.GA32052@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758744AbcIWMG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 08:06:27 -0400
In-Reply-To: <20160922213010.GA32052@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 22 Sep 2016 17:30:10 -0400

> On (09/22/16 01:52), David Miller wrote:
>> Alternatively we can do Alexander Duyck's trick, by pushing
>> the headers into the frag list, forcing a pull and realignment
>> by the next protocol layer.
> 
> What is the "Alexander Duyck trick" (hints about module or commit id,
> where this can be found, please)?
> 
> Is this basically about, e.g., putting the vxlanhdr in its own
> skb_frag_t, or something else?

Yes, and this way skb_header_pointer() is forced to do a memcpy.

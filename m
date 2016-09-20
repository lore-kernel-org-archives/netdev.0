From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 11:49:05 -0400
Message-ID: <20160920154905.GN8920@oracle.com>
References: <20160920142700.GJ8920@oracle.com>
 <CALx6S34c=Ftn1PfQ+YRDvbbWUmFW0R1zGC2jgkY0G7Fcx_SM7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Paolo Abeni <pabeni@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25788 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754001AbcITPtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:49:31 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S34c=Ftn1PfQ+YRDvbbWUmFW0R1zGC2jgkY0G7Fcx_SM7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/20/16 08:31), Tom Herbert wrote:
> 
> On Tue, Sep 20, 2016 at 7:27 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
> > The vxlan header is at offset (14 + 20 + 8) into the packet,
> > so the vxh is not aligned in vxlan_build_skb. Use [get/put]_unaligned
> > functions to modify flags and vni field in the vxh.
> >
> I'm wondering if VXLAN is just the tip of the iceberg. Wouldn't this
> is also be a problem in GRE and Geneve when they encapsulate Ethernet?
> What about the outer IP header, wouldn't that potentially have
> unaligned accesses also when creating it?

Indeed. All of the above are true, and we have to conquer
each unaligned access, one at a time.

There's also the over-arching problem of arbitrary encapsulations
introducing intervening headers that throw off alignment. 
That would be a design discussion to be had with the ietf.

--Sowmini

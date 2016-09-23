From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Fri, 23 Sep 2016 19:41:34 -0400
Message-ID: <20160923234134.GA6397@oracle.com>
References: <20160920190929.57ddaeb0@griffin>
 <20160922.015242.735026657310158125.davem@davemloft.net>
 <20160922213010.GA32052@oracle.com>
 <20160923.080618.678103827885223586.davem@davemloft.net>
 <CAKgT0UcoDb5T9xwfAq83cNwU=XAKZxf0TmPiJZQyHFPr82zggg@mail.gmail.com>
 <20160923172059.GB2484@oracle.com>
 <CAKgT0UeB5n3g4f1v_2nenjcayAi=eOPFSC7132ihXTZOztHRkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Benc <jbenc@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Paolo Abeni <pabeni@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30660 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752767AbcIWXmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 19:42:02 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UeB5n3g4f1v_2nenjcayAi=eOPFSC7132ihXTZOztHRkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/23/16 10:38), Alexander Duyck wrote:
> 
> So basically what I was thinking is we do something like reserving
> NET_IP_ALIGN and continue writing headers to skb->data, but we force
> the tracking for the inner headers into frag[0] so that we can keep
> the inner headers aligned without messing up the alignment for outer
> headers.  In theory the inner offset and all that would still be
> functional but might need a few tweaks.  You could probably even use
> the skb->encapsulation bit to indicate you are doing this.  You could
> almost think of it as us doing something like the inverse of
> pskb_pull_tail.  The general idea here is we want to actually leave
> the data in skb->data, but just reference it from frag[0] so that we
> don't accidentally pull in the 2 byte padding for alignment when
> transmitting the frame.

yes, I think something along this line could do the trick.. I tried
hacking it a bit today for vxlan, and it could be extended for all
these encaps protocols. Let me fix/test this more next week, maybe
we can discuss in Tokyo.

--Sowmini

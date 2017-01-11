From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 15:58:29 -0500
Message-ID: <20170111205829.GN24086@oracle.com>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
 <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
 <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
 <20170111195909.GL24086@oracle.com>
 <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Jonathan T. Leighton" <jtleight@udel.edu>, netdev@vger.kernel.org,
        edumazet@google.com, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48952 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbdAKU6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 15:58:37 -0500
Content-Disposition: inline
In-Reply-To: <1484167422.15816.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/11/17 12:43), Eric Dumazet wrote:
> 
> On Wed, 2017-01-11 at 14:59 -0500, Sowmini Varadhan wrote:
> 
> > I think the RFC states somewhere that you should never ever
> > send out a v4 mapped address on the wire.
> 
> Can you point the exact RFC ?
> 
> https://tools.ietf.org/html/rfc2765  seems to allow just that.

I have not read the details of 2765, but from a cursory look,
it talks about "IPv4-translatable addresses", not v4-mapped
addrs, and says,
"The address translation mechanisms for the stateless and the stateful
 translations are defined in [RFC6052]"
It's also not clear to me that 2765 warrants the use of these
as ip6 src, or ip6 dst, or the target(s) of NS/NA.

https://www.rfc-editor.org/rfc/rfc4038.txt refers to security
considerations about sending v4-mapped addrs on the wire
Looks like these security considerations are discussed in
 https://tools.ietf.org/html/draft-itojun-v6ops-v4mapped-harmful-02

In general, I think BSD and Solaris (and probably most
router implementations, esp the BSD-based ones) will not allow
v4 mapped addresses as src or dst of ip6 packets.

> Jonathan issue is about terminating such flows in TCP stack, which is
> likely not needed/useful.

sure. but if you configure the v4 mapped address as
a src addr "everything should be fine!"

--Sowmini

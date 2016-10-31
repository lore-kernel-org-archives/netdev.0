From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for
 forwarded ICMP errors from offending packet
Date: Mon, 31 Oct 2016 15:15:34 -0400 (EDT)
Message-ID: <20161031.151534.329043104568805244.davem@davemloft.net>
References: <CALx6S35qmAwFfK1TNAcJJs1jK7JgM8U4MCh3wC8hkuf2qae+sw@mail.gmail.com>
        <8760oa9egg.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945816AbcJaTPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:15:36 -0400
In-Reply-To: <8760oa9egg.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Sun, 30 Oct 2016 14:03:11 +0100

> 2) ensure the flow labels used in both directions are the same (either
>    reflected by one side, or fixed, e.g. not used and set to 0), so that
>    the 4-tuple we hash over when forwarding, <src addr, dst addr, flow
>    label, next hdr>, is the same both ways, modulo the order of
>    addresses.

Even Linux, by default, does not do reflection.

See the flowlabel_consistency sysctl, which we set by default to '1'.

I think we need to think a lot more about how systems actually set and
use flowlabels.

Also, one issue I also had with this series was adding a new member
to the flow label.  Is it possible to implement this like the ipv4
side did, by simply passing a new parameter around to the necessary
functions?

Thanks.

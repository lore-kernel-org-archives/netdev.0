From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [v3] net: ipv6: fallback to full lookup if table lookup is
 unsuitable
Date: Sun, 18 Sep 2016 09:47:59 -0600
Message-ID: <d4d7cc30-8b87-d29d-1df4-657fe192ace2@cumulusnetworks.com>
References: <8bce7180-e4c2-808c-20e0-0bd9634b8fc2@cumulusnetworks.com>
 <20160918154607.5474-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33681 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcIRPsC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:48:02 -0400
Received: by mail-pf0-f172.google.com with SMTP id 21so31701677pfy.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 08:48:02 -0700 (PDT)
In-Reply-To: <20160918154607.5474-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/18/16 9:46 AM, Vincent Bernat wrote:
> Commit 8c14586fc320 ("net: ipv6: Use passed in table for nexthop
> lookups") introduced a regression: insertion of an IPv6 route in a table
> not containing the appropriate connected route for the gateway but which
> contained a non-connected route (like a default gateway) fails while it
> was previously working:
> 
>     $ ip link add eth0 type dummy
>     $ ip link set up dev eth0
>     $ ip addr add 2001:db8::1/64 dev eth0
>     $ ip route add ::/0 via 2001:db8::5 dev eth0 table 20
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     RTNETLINK answers: No route to host
>     $ ip -6 route show table 20
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
> 
> After this patch, we get:
> 
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     $ ip -6 route show table 20
>     2001:db8:cafe::1 via 2001:db8::6 dev eth0  metric 1024  pref medium
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
> 
> Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
> Signed-off-by: Vincent Bernat <vincent@bernat.im>
> ---
>  net/ipv6/route.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>

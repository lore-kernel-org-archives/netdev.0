From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 23:22:19 +0300
Message-ID: <20160915202219.GB1867@uranus.lan>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34199 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbcIOUWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:22:23 -0400
Content-Disposition: inline
In-Reply-To: <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 01:53:13PM -0600, David Ahern wrote:
> On 9/13/16 11:19 AM, Cyrill Gorcunov wrote:
> > In criu we are actively using diag interface to collect sockets
> > present in the system when dumping applications. And while for
> > unix, tcp, udp[lite], packet, netlink it works as expected,
> > the raw sockets do not have. Thus add it.
> > 
> > v2:
> >  - add missing sock_put calls in raw_diag_dump_one (by eric.dumazet@)
> >  - implement @destroy for diag requests (by dsa@)
> > 
> > v3:
> >  - add export of raw_abort for IPv6 (by dsa@)
> >  - pass net-admin flag into inet_sk_diag_fill due to
> >    changes in net-next branch (by dsa@)
> > 
> > CC: David S. Miller <davem@davemloft.net>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: David Ahern <dsa@cumulusnetworks.com>
> > CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > CC: James Morris <jmorris@namei.org>
> > CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> > CC: Patrick McHardy <kaber@trash.net>
> > CC: Andrey Vagin <avagin@openvz.org>
> > CC: Stephen Hemminger <stephen@networkplumber.org>
> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> > ---
> 
> ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.
> 
> haven't had time to track down why there is a mismatch since the kill uses the socket returned
> from the dump. Won't have time to come back to this until early next week.

Have you ran iproute2 patched? I just ran ss -K and all sockets get closed
(including raw ones), which actually kicked me off the testing machine sshd :/

	Cyrill

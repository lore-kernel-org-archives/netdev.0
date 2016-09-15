From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 13:53:13 -0600
Message-ID: <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
References: <20160913171950.GC32643@uranus>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160913171950.GC32643@uranus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/13/16 11:19 AM, Cyrill Gorcunov wrote:
> In criu we are actively using diag interface to collect sockets
> present in the system when dumping applications. And while for
> unix, tcp, udp[lite], packet, netlink it works as expected,
> the raw sockets do not have. Thus add it.
> 
> v2:
>  - add missing sock_put calls in raw_diag_dump_one (by eric.dumazet@)
>  - implement @destroy for diag requests (by dsa@)
> 
> v3:
>  - add export of raw_abort for IPv6 (by dsa@)
>  - pass net-admin flag into inet_sk_diag_fill due to
>    changes in net-next branch (by dsa@)
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Ahern <dsa@cumulusnetworks.com>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> CC: James Morris <jmorris@namei.org>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Andrey Vagin <avagin@openvz.org>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---

ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.

haven't had time to track down why there is a mismatch since the kill uses the socket returned from the dump. Won't have time to come back to this until early next week.

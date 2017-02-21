From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v4 0/7] gtp: misc improvements
Date: Tue, 21 Feb 2017 12:13:22 +0100 (CET)
Message-ID: <1340046157.178143.1487675602597.JavaMail.zimbra@tpip.net>
References: <20170221101855.23940-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: laforge <laforge@gnumonks.org>, pablo <pablo@netfilter.org>,
        netdev <netdev@vger.kernel.org>
To: osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:56200 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751266AbdBULN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 06:13:27 -0500
In-Reply-To: <20170221101855.23940-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In case anyone want's to have a look at the changes that I'm working
on for follow up series can find them at:

  https://github.com/RoadRunnr/net-next/tree/gtp

Regards
Andreas

----- On Feb 21, 2017, at 11:18 AM, Andreas Schultz aschultz@tpip.net wrote:

> Hi Pablo,
> 
> This is v4 of the GTP improvements. Compared to v3 it contains mostly
> smallish naming and spelling fixes. It also drops the documentation
> patch, Harald did a better job with the documentation and the some things
> I described do not yet match the implementation. I'll readd the relevant
> parts with a follow up series.
> 
> This series lays the groundwork for removing the socket references from
> the GTP netdevice by removing duplicate code and simplifying the logic on
> some code paths.
> 
> It slighly changes the GTP genl API by making the socket parameters optional
> (though one of them is still required).
> 
> The removal of the socket references will break the 1:1 releation between
> GTP netdevice and GTP socket that prevents us to support multiple VRFs with
> overlaping IP addresse spaces attached to the same GTP-U entity (needed for
> multi APN support, comming a follow up series).
> 
> Pablo found a socket hold problem in v2. In order to solve that I had to
> switch the socket references from the struct socket to the internal
> struct sock. This should have no functionl impact, but we can now hang
> on to the reference without blocking user space from closing the GTP socket.
> 
> v3->v4:
> * drop the documentation patch
> * spelling fixes
> * pass nlattr instead of genl_info into gtp_find_dev,
>   makes the code slightly more compact and readable
> v2->v3:
> * add documentation to explain the goal of all these changes
> * incorporate review comments
> * switch from struct socket to struct sock
> 
> Regards
> Andreas
> 
> --
> Andreas Schultz (7):
>  gtp: switch from struct socket to struct sock for the GTP sockets
>  gtp: make GTP sockets in gtp_newlink optional
>  gtp: merge gtp_get_net and gtp_genl_find_dev
>  gtp: consolidate gtp socket rx path
>  gtp: unify genl_find_pdp and prepare for per socket lookup
>  gtp: consolidate pdp context destruction into helper
>  gtp: add socket to pdp context
> 
> drivers/net/gtp.c | 543 +++++++++++++++++++++++++++---------------------------
> 1 file changed, 269 insertions(+), 274 deletions(-)
> 
> --
> 2.10.2

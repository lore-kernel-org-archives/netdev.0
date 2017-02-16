From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v3 0/8] gtp: misc improvements
Date: Thu, 16 Feb 2017 22:38:00 +0100 (CET)
Message-ID: <2065178262.135524.1487281080405.JavaMail.zimbra@tpip.net>
References: <20170213153624.14170-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>
To: pablo <pablo@netfilter.org>, laforge <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:42363 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932975AbdBPViD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 16:38:03 -0500
In-Reply-To: <20170213153624.14170-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo, Harald,

Do you have some time to look at the patches?

Andreas

----- On Feb 13, 2017, at 4:36 PM, Andreas Schultz aschultz@tpip.net wrote:

> Hi Pablo,
> 
> This is v3 of the GTP improvements.
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
> multi APN support).
> 
> Pablo found a socket hold problem in v2. In order to solve that I had to
> switch the socket references from the struct socket to the internal
> struct sock. This should have no functionl impact, but we can now hang
> on to the reference without blocking user space from closing the GTP socket.
> 
> There was also some length off-list conversation about why the netdevice to
> socket relation needs to be changed at all. Harald did already agree to this
> but Pablo had some questions. I've tried to address that with a bit of
> dokumentation for the GTP module. Hopefully this will explain the need for
> the change sufficiently.
> 
> This series does have conflicts with the SGSN side tunnel work done by
> Jonas Bonn. The unification of the tunnel Rx code touches the same places
> he changed.
> 
> v2->v3:
> * add documentation to explain the goal of all these changes
> * incorporate review comments
> * switch from struct socket to struct sock
> 
> Regards
> Andreas
> 
> --
> Andreas Schultz (8):
>  gtp: add documentation
>  gtp: switch from struct socket to struct sock for the GTP sockets
>  gtp: make GTP sockets in gtp_newlink optional
>  gtp: merge gtp_get_net and gtp_genl_find_dev
>  gtp: consolidate gtp socket rx path
>  gtp: unify genl_find_pdp and prepare for per socket lookup
>  gtp: consolidate pdp context destruction into helper
>  gtp: add socket to pdp context
> 
> Documentation/networking/gtp.txt | 112 ++++++++
> drivers/net/gtp.c                | 548 +++++++++++++++++++--------------------
> 2 files changed, 386 insertions(+), 274 deletions(-)
> create mode 100644 Documentation/networking/gtp.txt
> 
> --
> 2.10.2

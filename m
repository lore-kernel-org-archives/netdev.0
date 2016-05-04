From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 0/3] gre: receive also TEB packets for lwtunnels
Date: Wed, 4 May 2016 16:52:53 +0900
Message-ID: <20160504075250.GA25241@penelope.isobedori.kobe.vergenet.net>
References: <cover.1462286214.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35099 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757295AbcEDHxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 03:53:01 -0400
Received: by mail-pa0-f50.google.com with SMTP id iv1so21256773pac.2
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 00:53:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1462286214.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 05:10:05PM +0200, Jiri Benc wrote:
> NOTE: this patchset needs net merged to net-next.
> 
> This allows lwtunnel users to get also packets with ETH_P_TEB protocol
> specified in GRE header through an ipgre interface. There's really nothing
> special about these packets in the case of lwtunnels - it's just an inner
> protocol like any other. The only complications stem from keeping
> compatibility with other uses of GRE.
> 
> This will be used by openvswitch to support eth_push and eth_pop actions.
> I'd also like to see tc support for lwtunnels (this feature included) in the
> future.
> 
> The first patch is not directly related and can be submitted standalone if
> needed.

I have exercised this patch-set using Open vSwitch both with
and without the patchset I posted earlier this afternoon to
make use of this new feature:

"[PATCH v9 net-next 0/7] openvswitch: support for layer 3 encapsulated packets"

All three patches:

Tested-by: Simon Horman <simon.horman@netronome.com>

> Jiri Benc (3):
>   gre: remove superfluous pskb_may_pull
>   gre: move iptunnel_pull_header down to ipgre_rcv
>   gre: receive also TEB packets for lwtunnels
> 
>  include/net/ip_tunnels.h |  1 +
>  net/ipv4/gre_demux.c     |  5 +----
>  net/ipv4/ip_gre.c        | 48 +++++++++++++++++++++++++++++++++++-------------
>  3 files changed, 37 insertions(+), 17 deletions(-)
> 
> -- 
> 1.8.3.1
> 

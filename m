From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 5/5] netlink: pass extended ACK struct where
 available
Date: Wed, 12 Apr 2017 16:00:43 +0200
Message-ID: <20170412140043.GH1952@nanopsycho>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-6-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34413 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbdDLOAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:00:46 -0400
Received: by mail-wm0-f66.google.com with SMTP id x75so6599356wma.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 07:00:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170412123408.22012-6-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 12, 2017 at 02:34:08PM CEST, johannes@sipsolutions.net wrote:
>From: Johannes Berg <johannes.berg@intel.com>
>
>This is an add-on to the previous patch that passes
>the extended ACK structure where it's already available
>by existing genl_info or extack function arguments.
>
>This was done with this spatch (with some manual
>adjustment of indentation):
>
>@@
>expression A, B, C, D, E;
>identifier fn, info;
>@@
>fn(..., struct genl_info *info, ...) {
>...
>-nlmsg_parse(A, B, C, D, E, NULL)
>+nlmsg_parse(A, B, C, D, E, info->extack)
>...
>}
>
>@@
>expression A, B, C, D, E;
>identifier fn, info;
>@@
>fn(..., struct genl_info *info, ...) {
><...
>-nla_parse_nested(A, B, C, D, NULL)
>+nla_parse_nested(A, B, C, D, info->extack)
>...>
>}
>
>@@
>expression A, B, C, D, E;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
><...
>-nlmsg_parse(A, B, C, D, E, NULL)
>+nlmsg_parse(A, B, C, D, E, extack)
>...>
>}
>
>@@
>expression A, B, C, D, E;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
><...
>-nla_parse(A, B, C, D, E, NULL)
>+nla_parse(A, B, C, D, E, extack)
>...>
>}
>
>@@
>expression A, B, C, D, E;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
>...
>-nlmsg_parse(A, B, C, D, E, NULL)
>+nlmsg_parse(A, B, C, D, E, extack)
>...
>}
>
>@@
>expression A, B, C, D;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
><...
>-nla_parse_nested(A, B, C, D, NULL)
>+nla_parse_nested(A, B, C, D, extack)
>...>
>}
>
>@@
>expression A, B, C, D;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
><...
>-nlmsg_validate(A, B, C, D, NULL)
>+nlmsg_validate(A, B, C, D, extack)
>...>
>}
>
>@@
>expression A, B, C, D;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
><...
>-nla_validate(A, B, C, D, NULL)
>+nla_validate(A, B, C, D, extack)
>...>
>}
>
>@@
>expression A, B, C;
>identifier fn, extack;
>@@
>fn(..., struct netlink_ext_ack *extack, ...) {
><...
>-nla_validate_nested(A, B, C, NULL)
>+nla_validate_nested(A, B, C, extack)
>...>
>}
>
>Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>---
> crypto/crypto_user.c           |  2 +-
> drivers/net/team/team.c        |  3 ++-
> net/ieee802154/nl802154.c      | 10 +++++-----
> net/netfilter/ipvs/ip_vs_ctl.c |  2 +-
> net/netfilter/nfnetlink.c      |  2 +-
> net/netlink/genetlink.c        |  2 +-
> net/nfc/netlink.c              |  2 +-
> net/tipc/bearer.c              | 14 +++++++-------
> net/tipc/net.c                 |  2 +-
> net/tipc/node.c                |  8 ++++----
> net/wireless/nl80211.c         | 33 ++++++++++++++++++---------------
> net/xfrm/xfrm_user.c           |  2 +-
> 12 files changed, 43 insertions(+), 39 deletions(-)

Aside from the tinyfication of desc lines, this looks good to me

Reviewed-by: Jiri Pirko <jiri@mellanox.com>

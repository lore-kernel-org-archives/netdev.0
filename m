From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v12] openvswitch: enable NSH support
Date: Thu, 19 Oct 2017 14:43:47 +0200
Message-ID: <20171019144347.421351db@griffin>
References: <1508162009-30359-1-git-send-email-yi.y.yang@intel.com>
        <20171018231955.058ec5c8@griffin>
        <20171019114052.GA83037@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "pshelar@ovn.org" <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38404 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752643AbdJSMnz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 08:43:55 -0400
In-Reply-To: <20171019114052.GA83037@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Oct 2017 19:40:53 +0800, Yang, Yi wrote:
> Actually mdtype can't be set, only push_nsh can set mdtype, so set_nsh
> won't have mdtype flow key, we can't get it from flow_key in set_nsh,
> only ttl, flags and path_hdr can be set in set_nsh as you can see in code.
> I understand your concern is calling skb_ensure_writable twice, so
> changing the first one to pskb_may_pull is more appropriate for set_nsh.

Isn't set_nsh called only after the packet was already dissected (i.e.
parse_nsh called)? The dissected fields should be available in flow_key.

 Jiri

From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 14:57:44 +0200
Message-ID: <20170904145744.4d8b7fd5@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
        <20170831124516.0c5db686@griffin>
        <20170904080005.GA70767@cran64.bj.intel.com>
        <20170904124216.6db68e8c@griffin>
        <20170904120907.GA75461@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61481 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753543AbdIDM5z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 08:57:55 -0400
In-Reply-To: <20170904120907.GA75461@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Sep 2017 20:09:07 +0800, Yang, Yi wrote:
> So we must do many changes if we want to break this assumption.

We may do as many changes as we want to. This is uAPI we're talking
about and we need to get it right since the beginning. Sure, it may
mean that some user space programs need some changes in order to make
use of the new features. That happens every day.

I also don't understand where's the problem. It's very easy to check
for NLA_F_NESTED and generically act based on that in the function you
quoted. Just call a different function than format_odp_key_attr to
handle ovs_nsh_key_attr attributes in case the nested flag is set and
the attribute is OVS_KEY_ATTR_NSH and you're done. You'll need such
function anyway, it's not much different code size wise to call it from
format_odp_key_attr or from format_odp_action.

 Jiri

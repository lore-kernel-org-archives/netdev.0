From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 12:49:14 +0200
Message-ID: <20170926124914.60101ca1@griffin>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
        <20170925201439.08460295@griffin>
        <20170926045538.GA5896@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967914AbdIZKtT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 06:49:19 -0400
In-Reply-To: <20170926045538.GA5896@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 12:55:39 +0800, Yang, Yi wrote:
> After push_nsh, the packet won't be recirculated to flow pipeline, so
> key->eth.type must be set explicitly here, but for pop_nsh, the packet
> will be recirculated to flow pipeline, it will be reparsed, so
> key->eth.type will be set in packet parse function, we needn't handle it
> in pop_nsh.

This seems to be a very different approach than what we currently have.
Looking at the code, the requirement after "destructive" actions such
as pushing or popping headers is to recirculate.

Setting key->eth.type to satisfy conditions in the output path without
updating the rest of the key looks very hacky and fragile to me. There
might be other conditions and dependencies that are not obvious.
I don't think the code was written with such code path in mind.

I'd like to hear what Pravin thinks about this.

 Jiri

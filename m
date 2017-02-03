From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Thu, 02 Feb 2017 20:50:53 -0500 (EST)
Message-ID: <20170202.205053.1531692095462887882.davem@davemloft.net>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35708 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdBCBu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:50:57 -0500
In-Reply-To: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I see a lot of "complexity of bridging layer" pushback on these
changes, and I understand where that is coming from.

But really this isn't even, at a high level, really a bridging change.

What it's doing is making lwtunnel objects more useful.

Now that we have lightweight tunnels and netdevs, we will constantly
have this struggle trying to figure out how to make lwtunnel objects
apply to the same cases that netdevs currently only work for.

Because once you run into one of these situations where only netdevs
work, you are screwed and lwtunnels and their scalability benefit
might as well not even exist.

To be completely honest, in this case it's pretty clear:

1) It makes vxlan lwtunnel objects more usable for bridges.

2) It does not make lwtunnels more bloated or consume more memory
   or cpu in the dataplane fast paths.

3) It makes uptake of lwtunnels higher, because they can be used
   in more places.

So I think this change is a win and a move forward.

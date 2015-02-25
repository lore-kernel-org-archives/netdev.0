From: ebiederm@xmission.com (Eric W. Biederman)
Subject: What are the intended semantics of IFLA_LINK_NETNSID?
Date: Wed, 25 Feb 2015 13:03:01 -0600
Message-ID: <871tldstju.fsf_-_@x220.int.ebiederm.org>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42252 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbbBYTGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 14:06:30 -0500
In-Reply-To: <54EDF7BB.2060809@6wind.com> (Nicolas Dichtel's message of "Wed,
	25 Feb 2015 17:26:35 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reading through the code of rtnl_newlink I am perplexed with what your
intended semantics of IFLA_LINK_NETNSID are supposed to be.

My expectation was something with the same semantics IFLA_NET_NS_PID and
IFLA_NET_NS_FD just a different data representation and something that
could be used in more netlink messages, so you could report the network
namespace where the other end of a tunnel or the the network namespace
of an underlying device is.

Being very slow I would expect that ILFA_LINK_NETNSID would replace
dest_net or possibly net in rtnl_newlink but it does not replace either
of those completely.  Which causes me to think that the implementation
of IFLA_LINK_NETNSID in rtnl_newlink is broken.

I suspect the correct fix for rtnl_newlink is to just use
IFLA_LINK_NETNSID in rtnl_link_get_net and have it be an alternative way
of setting dest_net.  But you may intend some different semantics that
I don't understand.

Eric

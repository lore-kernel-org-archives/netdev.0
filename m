From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][v2] Netfilter Kconfig: Expose IPv4/6 connection tracking
 options by selecting NF_CONNTRACK_ENABLED
Date: Thu, 26 Jul 2007 02:46:05 +0200
Message-ID: <46A7EECD.9070801@trash.net>
References: <200707251802.22200.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Sam Ravnborg <sam@ravnborg.org>
To: Al Boldi <a1426z@gawab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62691 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbXGZArS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:47:18 -0400
In-Reply-To: <200707251802.22200.a1426z@gawab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Removed a few CCs]

Al Boldi wrote:
> Make NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6 select NF_CONNTRACK_ENABLED.


One thought that occured to me after the last of many false bugreports
that were actually caused by failure to configure the new options
properly. Most people know they want NF_CONNTRACK (and its selected by
default with old configs), what they're missing is that they now also
need to select IPv4 connection tracking. So what would really make sense
is to make NF_CONNTRACK_IPV4 default to "m" (and really *everyone*
using conntrack wants this). But with your proposed change this would
default to selecting NF_CONNTRACK by default, which I'm not so sure
is a good idea. So I'm leaning towards just using "m" as default for
IPv4 conntrack to save people trouble and myself some bugreports, but
I also like your simplification ...

Maybe we can do something to have the NF_CONNTRACK_ENABLED option select
NF_CONNTRACK_IPV4 (which really is what we actually want) and combine
that with automatic selection of NF_CONNTRACK? I believe the only case
with negative impact would be people that currently use only IPv6
connection tracking, which is most likely nobody.


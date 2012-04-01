From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: ipv6: RTM_GETROUTE inconsistent interpretation of RTA_IIF
Date: Sun, 1 Apr 2012 09:18:07 +0300
Message-ID: <20120401091807.2f4614f2@pixies.home.jungo.com>
References: <20120329150311.51fe0e2d@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43854 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab2DAGSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 02:18:17 -0400
Received: by wejx9 with SMTP id x9so1104220wej.19
        for <netdev@vger.kernel.org>; Sat, 31 Mar 2012 23:18:16 -0700 (PDT)
In-Reply-To: <20120329150311.51fe0e2d@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Bump)

Any reason not to submit a patch that fixes the below issue?

Regards,
Shmulik

On Thu, 29 Mar 2012 15:03:11 +0200 Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> Hi,
> 
> In IPv4, if the RTA_IIF attribute is specified in an RTM_GETROUTE
> message, then a route is searched as if a packet was received on the
> specified iif interface - i.e. 'inet_rtm_getroute()' calls
> 'ip_route_input()'.
> 
> However in IPv6, RTA_IIF is not interpreted in the same way:
> 'inet6_rtm_getroute()' always calls 'ip6_route_output()', regardless the
> RTA_IIF attribute.
> 
> As a result, in IPv6 there's no way to use RTM_GETROUTE in order to look
> for a route as if a packet was received on a specific interface.
> 
> I'd like to modify 'inet6_rtm_getroute()' so that RTA_IIF is interpreted
> in the same way as in IPv4's 'inet_rtm_getroute()'.
> 
> Before I come up with a patch, I'd like to know whether current
> interpretation of RTA_IIF in 'inet6_rtm_getroute()' is deliberate.

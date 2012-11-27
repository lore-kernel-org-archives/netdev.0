From: Glauber Costa <glommer@parallels.com>
Subject: Re: [net-next RFC v2] net_cls: traffic counter based on classification
 control cgroup
Date: Tue, 27 Nov 2012 15:03:06 +0400
Message-ID: <50B49DEA.7010000@parallels.com>
References: <50B49C6C.8030604@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <cgroups@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Daniel Wagner <wagi@monom.org>
To: Alexey Perevalov <a.perevalov@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:43258 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256Ab2K0LDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:03:13 -0500
In-Reply-To: <50B49C6C.8030604@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2012 02:56 PM, Alexey Perevalov wrote:
> Hello.
> 
> It's second version of patch I already sent to netdev.
> 
> The main goal of this patch it's counting traffic for process placed to
> net_cls cgroup (ingress and egress).
> It's based on res_counters and holds counter per network interfaces.
> 
> Description of patch.
> It handles packets in net/core/dev.c for egress and in
> /net/ipv4/tcp.c|udp.c for ingress.
> These places were chosen because we need to know also network interface.
> 
> Cgroup fs interface provides following files additional to existing
> net_cls files:
> net_cls.ifacename.usage_in_bytes
> Containing rcv/snd lines.
> Also this patch adds to net_cls ability to handle a network device
> registration.
> 
> It could be included or excluded in compile time.
> I moved the menu entry for "Control group classifier" from network/QoS to
> General Option/Control Group.
> 
> I'm waiting for you comments.
>

Daniel Wagner is working on something a lot similar.

Maybe you should be in contact, in case you are not yet.

A few general comments:
1) res_counters are incredibly expensive. If you are more interested in
counting than you are in limiting, they may not be your best choice.

2) When Daniel exposed his use case to me, it gave me the impression
that "counting traffic" is something that is totally doable by having a
dedicated interface in a separate namespace. Basically, we already count
traffic (rx and tx) for all interfaces anyway, so it suggests that it
could be an interesting way to see the problem.

AFAIK, Daniel is still measuring this. But it would be great to know if
that could work for your use case as well.

Thanks.

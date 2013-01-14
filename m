From: Daniel Wagner <wagi@monom.org>
Subject: Re: [RFC PATCH v3] cgroup: net_cls: traffic counter based on classification
 control cgroup
Date: Mon, 14 Jan 2013 09:09:10 +0100
Message-ID: <50F3BD26.6090903@monom.org>
References: <50F04502.9090902@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org
To: Alexey Perevalov <a.perevalov@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:36238 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755659Ab3ANIJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 03:09:12 -0500
In-Reply-To: <50F04502.9090902@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexey,

On 11.01.2013 17:59, Alexey Perevalov wrote:
> I'm sorry for previous email with attachments.

It seems something went wrong with the patch, e.g. indention is wrong 
and also I see '^M$' line endings. I assume you are sending your patches 
through an exchange server which is likely not to work.

> I would like to represent next version of patch I sent before
> cgroup: "net_cls: traffic counter based on classification control cgroup"
>
> The main idea is the same as was. It keeping counter in control groups,
> but now uses atomic instead resource_counters.

+#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
+ if (copied > 0)
+ count_cls_rcv(current, copied, ifindex);
+#endif
+
release_sock(sk);
return copied;

Normally, distros will enable most config flags. Maybe you could use
a jump label to reduce the cost for the users which have 
CONFIG_NET_CLS_COUNTER enabled and do not use it?

> I have a performance measurement for this patch. It was done by lmbench
> on physical machine.
> Results are not so representative for 20 tests and some numbers are real
> weird.

Could you explain in the commit message how your patch is designed? I 
see you are using a RB tree. What's the purpose of it?

> Daniel Wagner wrote what he is doing something similar, but using
> namespaces.

I am trying a different approach on this problem using iptables. I am 
playing around with a few patches which allow to install a iptables rule
which matches on the security context, e.g.

iptables -t mangle -A OUTPUT -m secmark --secctx \
unconfined_u:unconfined_r:foo_t:s0-s0:c0.c1023 -j MARK --set-mark 1

So far it looks promising, but as I me previous networking experience 
is, that something will not work eventually.

> Proposed by me approach is used in upcoming Tizen release, but little
> bit different version.

Thanks,
Daniel

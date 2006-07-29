From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][SECURITY] secmark: nul-terminate secdata
Date: Sat, 29 Jul 2006 03:19:03 +0200
Message-ID: <44CAB787.8040204@trash.net>
References: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47070 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1161401AbWG2BTG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 21:19:06 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> The patch below fixes a problem in the iptables SECMARK target, where the 
> user-supplied 'selctx' string may not be nul-terminated.
> 
>>From initial analysis, it seems that the strlen() called from 
> selinux_string_to_sid() could run until it arbitrarily finds a zero, and 
> possibly cause a kernel oops before then.
> 
> The impact of this appears limited because the operation requires 
> CAP_NET_ADMIN, which is essentially always root.  Also, the module is not 
> yet in wide use.
> 
> Please apply.
> 
> Note: some other iptables modules which handle strings supplied from 
> userspace may require a similar fix (e.g. xt_string looks suspect at first 
> glance).


I'll look into these, but it won't be the last of these problems. At the
last netfilter workshop Rusty spent some time figuring out "how many
iptables crashes (triggered by root) can I find in a few minutes", and
it was quite a lot. So far we've hoped for pkttables to make everything
better, but it looks like things like OpenVZ will beat us.


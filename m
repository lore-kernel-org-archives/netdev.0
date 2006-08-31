From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 0/3] secid reconciliation-v01: Repost patchset with up
  dates
Date: Thu, 31 Aug 2006 10:45:09 -0400
Message-ID: <44F6F5F5.5000408@hp.com>
References: <36282A1733C57546BE392885C061859201512B64@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, Stephen Smalley <sds@tycho.nsa.gov>,
	Chad Hanson <chanson@TrustedCS.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:47280 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751244AbWHaOpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 10:45:11 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C061859201512B64@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>My main concern with these patches is that moving the 
>>NetLabel check out
>>of selinux_socket_sock_rcv_skb() and into 
>>selinux_skb_policy_check() (as
>>it is currently written) would force us to compare a packet's NetLabel
>>with either the IPsec label or the secmark label
> 
> Yes you would do these checks (while using a netlabel based off of the
> secmark at that point) to enforce flow control and when they succeed,
> you will copy netlabel into secmark.
> 
>>and not the socket's
>>label.
> 
> The socket Vs. secmark check that happens later in rcv_skb will in fact be
> looking at the cipso label that is by then a part of the secmark context.

So what you envison is that when an MLS label is found on a packet using
NetLabel the MLS label from the packet is attached to the secmark
context (replacing the existing MLS label, if any) and the resulting
context would be checked for a "flow_in" permission, yes?

Assuming the permission is granted the packet's secmark is replaced with
the updated context.  This updated secmark context would then be used in
sock_rcv_skb() to make an access decision, yes?

>> The ability to make access decisions based on the process
>>consuming the data and the data itself it one of the nicer 
>>qualities of
>>NetLabel in my opinion.
> 
> This nicer quality ends up being preserved as explained above :)

It wasn't clear to me from your patch or the "master plan" what you
intended to do with the NetLabel context.  I thought the "/* See if
CIPSO can flow in thru the current secmark here */" comment in your
patch was rather cryptic.

> We just need to get out of the mindset of viewing netlabel separately
> once we are past the reconciliation point.

Agreed.  Although to be honest, I think the NetLabel context can be
reconciled with the secmark and XFRM contexts just as easily using the
existing sock_rcv_skb() hook.  I guess I need to see where the
xfrm[4|6]_policy_check() hooks are called from in the stack to better
understand ...

-- 
paul moore
linux security @ hp

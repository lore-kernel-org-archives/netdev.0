From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/9] secid reconciliation-v04: Enforcement for SELinux
Date: Mon, 02 Oct 2006 12:58:49 -0400
Message-ID: <45214549.5040303@hp.com>
References: <452032A6.1080306@trustedcs.com>  <45213A55.8070205@hp.com> <1159806908.6855.58.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@trustedcs.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:27801 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S965082AbWJBQ6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 12:58:55 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <1159806908.6855.58.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Smalley wrote:
> On Mon, 2006-10-02 at 12:12 -0400, Paul Moore wrote:
> 
>>Venkat Yekkirala wrote:
>>
>>>This defines SELinux enforcement of the 2 new LSM hooks as well
>>>as related changes elsewhere in the SELinux code.
>>>
>>>This also now keeps track of the peersid thru the establishment
>>>of a connection on the server (tracking peersid on the client
>>>is covered later in this patch set).
>>>
>>>Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
>>>
>>>{snip}
>>>
>>>+static int selinux_skb_flow_in(struct sk_buff *skb, unsigned short family)
>>>+{
>>>+	u32 xfrm_sid;
>>>+	int err;
>>>+
>>>+	if (selinux_compat_net)
>>>+		return 1;
>>>+
>>>+	/*
>>>+	 * loopback traffic already labeled and
>>>+	 * flow-controlled on outbound. We may
>>>+	 * need to flow-control on the inbound
>>>+	 * as well if there's ever a use-case for it.
>>>+	 */
>>>+	if (skb->dev == &loopback_dev)
>>>+		return 1;
>>>+
>>>+	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
>>>+	BUG_ON(err);
>>
>>Just a quick question that has been nagging me for awhile - any
>>particular reason why this is a BUG_ON() and not an "if (err) goto out;"?
>  
> It appears that selinux_xfrm_decode_session() can only legitimately
> return an error if the last argument (ckall) is non-zero.
> security_skb_classify_flow() was doing the same thing prior to this
> patch series.  It would be clearer if there were two separate interfaces
> that internally use the same helper, with one of the functions returning
> void.

My immediate concern is not really what selinux_xfrm_decode_session()
returns, but how to handle it, or rather errors in general, in
selinux_skb_flow_in().  I'm in the process of creating a patch to add
the missing NetLabel support to the secid patches and I am wondering if
I should BUG_ON() for an error condition or simply jump to "out".
Jumping seems a bit cleaner to me, although perhaps harder to debug, so
I was just wondering what the reasoning was behind the use of BUG_ON().

I honestly don't care at this point, it's a rather minor detail, I'd
just like to "do the right thing" with the NetLabel patch.

-- 
paul moore
linux security @ hp

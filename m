From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch net-next v2 1/3] team: handle sending port list in the
 same way option list is sent
Date: Sat, 2 Feb 2013 02:29:28 +0100
Message-ID: <20130202012927.GA4425@localhost>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
 <1359742646-1485-2-git-send-email-jiri@resnulli.us>
 <20130201183045.GA5822@localhost>
 <20130201190026.GA1627@minipsycho.brq.redhat.com>
 <20130201204310.GA3793@localhost>
 <20130201233147.GB1627@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([174.127.110.175]:11298 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756967Ab3BBB3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:29:33 -0500
Content-Disposition: inline
In-Reply-To: <20130201233147.GB1627@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 02, 2013 at 12:31:47AM +0100, Jiri Pirko wrote:
> Fri, Feb 01, 2013 at 09:43:10PM CET, pablo@netfilter.org wrote:
> >On Fri, Feb 01, 2013 at 08:00:26PM +0100, Jiri Pirko wrote:
> >> >> +send_done:
> >> >> +	nlh = nlmsg_put(skb, portid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
> >> >> +	if (!nlh) {
> >> >> +		err = __send_and_alloc_skb(&skb, team, portid, send_func);
> >> >> +		if (err)
> >> >> +			goto errout;
> >> >> +		goto send_done;
> >> >> +	}
> >> >
> >> >I'd suggest to use netlink_dump_start for this, so you don't need to
> >> >manually create the NLMSG_DONE message.
> >> 
> >> I believe that is not possible for genl
> >
> >By looking at net/netlink/genetlink.c, you can make it by means of the
> >.dumpit callback in struct genl_ops. You have to pass NLM_F_DUMP from
> >user-space to hit that code.
> 
> Correct. But I need to do unsolicited multicast messages as well. And
> that can't be resolved by dumpit.

Interesting. Why do you need multi-part multicast event messages?

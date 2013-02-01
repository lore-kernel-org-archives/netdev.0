From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/3] team: handle sending port list in the
 same way option list is sent
Date: Sat, 2 Feb 2013 00:31:47 +0100
Message-ID: <20130201233147.GB1627@minipsycho.brq.redhat.com>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
 <1359742646-1485-2-git-send-email-jiri@resnulli.us>
 <20130201183045.GA5822@localhost>
 <20130201190026.GA1627@minipsycho.brq.redhat.com>
 <20130201204310.GA3793@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fbl@redhat.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:49640 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758057Ab3BAXbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 18:31:50 -0500
Received: by mail-ea0-f173.google.com with SMTP id i1so1970232eaa.18
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 15:31:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130201204310.GA3793@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 01, 2013 at 09:43:10PM CET, pablo@netfilter.org wrote:
>On Fri, Feb 01, 2013 at 08:00:26PM +0100, Jiri Pirko wrote:
>> >> +send_done:
>> >> +	nlh = nlmsg_put(skb, portid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
>> >> +	if (!nlh) {
>> >> +		err = __send_and_alloc_skb(&skb, team, portid, send_func);
>> >> +		if (err)
>> >> +			goto errout;
>> >> +		goto send_done;
>> >> +	}
>> >
>> >I'd suggest to use netlink_dump_start for this, so you don't need to
>> >manually create the NLMSG_DONE message.
>> 
>> I believe that is not possible for genl
>
>By looking at net/netlink/genetlink.c, you can make it by means of the
>.dumpit callback in struct genl_ops. You have to pass NLM_F_DUMP from
>user-space to hit that code.

Correct. But I need to do unsolicited multicast messages as well. And
that can't be resolved by dumpit.

>
>BTW, perhaps it is good idea to keep the old get function that takes
>no NLM_F_DUMP for a while to avoid breaking old versions of userspace
>code?

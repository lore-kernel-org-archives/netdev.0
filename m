From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/3] team: handle sending port list in the
 same way option list is sent
Date: Fri, 1 Feb 2013 20:00:26 +0100
Message-ID: <20130201190026.GA1627@minipsycho.brq.redhat.com>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
 <1359742646-1485-2-git-send-email-jiri@resnulli.us>
 <20130201183045.GA5822@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fbl@redhat.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:35021 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab3BATAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 14:00:30 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so2253636eek.18
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 11:00:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130201183045.GA5822@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +send_done:
>> +	nlh = nlmsg_put(skb, portid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
>> +	if (!nlh) {
>> +		err = __send_and_alloc_skb(&skb, team, portid, send_func);
>> +		if (err)
>> +			goto errout;
>> +		goto send_done;
>> +	}
>
>I'd suggest to use netlink_dump_start for this, so you don't need to
>manually create the NLMSG_DONE message.
>

I believe that is not possible for genl

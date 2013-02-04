From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/3] team: handle sending port list in the
 same way option list is sent
Date: Mon, 4 Feb 2013 17:28:06 +0100
Message-ID: <20130204162806.GA1544@minipsycho.orion>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
 <1359742646-1485-2-git-send-email-jiri@resnulli.us>
 <20130201183045.GA5822@localhost>
 <20130201190026.GA1627@minipsycho.brq.redhat.com>
 <20130201204310.GA3793@localhost>
 <20130201233147.GB1627@minipsycho.brq.redhat.com>
 <20130202012927.GA4425@localhost>
 <20130202090422.GA1864@minipsycho.orion>
 <20130204160303.GA22732@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fbl@redhat.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:58224 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405Ab3BDQ2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 11:28:11 -0500
Received: by mail-wg0-f51.google.com with SMTP id 8so4754488wgl.18
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 08:28:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130204160303.GA22732@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 04, 2013 at 05:03:04PM CET, pablo@netfilter.org wrote:
>On Sat, Feb 02, 2013 at 10:04:22AM +0100, Jiri Pirko wrote:
>> Sat, Feb 02, 2013 at 02:29:28AM CET, pablo@netfilter.org wrote:
>> >On Sat, Feb 02, 2013 at 12:31:47AM +0100, Jiri Pirko wrote:
>> >> Fri, Feb 01, 2013 at 09:43:10PM CET, pablo@netfilter.org wrote:
>> >> >On Fri, Feb 01, 2013 at 08:00:26PM +0100, Jiri Pirko wrote:
>> >> >> >> +send_done:
>> >> >> >> +	nlh = nlmsg_put(skb, portid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
>> >> >> >> +	if (!nlh) {
>> >> >> >> +		err = __send_and_alloc_skb(&skb, team, portid, send_func);
>> >> >> >> +		if (err)
>> >> >> >> +			goto errout;
>> >> >> >> +		goto send_done;
>> >> >> >> +	}
>> >> >> >
>> >> >> >I'd suggest to use netlink_dump_start for this, so you don't need to
>> >> >> >manually create the NLMSG_DONE message.
>> >> >> 
>> >> >> I believe that is not possible for genl
>> >> >
>> >> >By looking at net/netlink/genetlink.c, you can make it by means of the
>> >> >.dumpit callback in struct genl_ops. You have to pass NLM_F_DUMP from
>> >> >user-space to hit that code.
>> >> 
>> >> Correct. But I need to do unsolicited multicast messages as well. And
>> >> that can't be resolved by dumpit.
>> >
>> >Interesting. Why do you need multi-part multicast event messages?
>> 
>> Messages are too big to fit one GENLMSG_DEFAULT_SIZE message.
>
>nfnetlink_log may use bigger messages than 1 memory page to deliver
>multicast events if configured to include the entire packet
>(NFULNL_COPY_PACKET).
>
>I'd suggest to calculate the message size in run-time and allocate
>memory you need according to that, several netfilter subsystem are
>doing so.

I recall I had some issues with longer messages on the userspace part,
I'm not sure what that was exactly. I decided to do this in multipart
messages and in order to do not break userspace I would like to continue
to do so.

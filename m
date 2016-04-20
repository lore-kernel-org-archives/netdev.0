From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 WIP] ifstat: use new RTM_GETSTATS api
Date: Wed, 20 Apr 2016 13:25:05 -0700
Message-ID: <5717E5A1.6020403@cumulusnetworks.com>
References: <1461168975-28081-1-git-send-email-roopa@cumulusnetworks.com> <20160420115347.6a43d7f7@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35654 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcDTUZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:25:09 -0400
Received: by mail-pf0-f180.google.com with SMTP id n1so21752810pfn.2
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 13:25:08 -0700 (PDT)
In-Reply-To: <20160420115347.6a43d7f7@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/16, 11:53 AM, Stephen Hemminger wrote:
> On Wed, 20 Apr 2016 09:16:15 -0700
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> +int rtnl_wilddump_stats_req_filter(struct rtnl_handle *rth, int family, int type,
>> +				   __u32 filt_mask)
>> +{
>> +	struct {
>> +		struct nlmsghdr nlh;
>> +		struct if_stats_msg ifsm;
>> +	} req;
> Please use C99 initialization instead of memset in new code.

yes, ack.
>
>> +	int err;
>> +
>> +	memset(&req, 0, sizeof(req));
>> +	req.nlh.nlmsg_len = sizeof(req);
>> +	req.nlh.nlmsg_type = type;
>> +	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
>> +	req.nlh.nlmsg_pid = 0;
>> +	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
>> +	req.ifsm.family = family;
>> +	req.ifsm.filter_mask = filt_mask;
>> +
>> +	err = send(rth->fd, (void*)&req, sizeof(req), 0);
>> +
>> +	return err;
> Why not just:
>         return send(rth->fd, &req, sizoef(req), 0);

yes, i had that initially. and then changed it to add some debugs before returning.

this is all WIP. will clean it up.

thanks.

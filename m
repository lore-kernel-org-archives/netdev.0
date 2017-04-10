From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 09:26:05 -0600
Message-ID: <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
 <20170408202434.12018-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34313 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753931AbdDJP0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:26:08 -0400
Received: by mail-pg0-f41.google.com with SMTP id 21so107672340pgg.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:26:08 -0700 (PDT)
In-Reply-To: <20170408202434.12018-2-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/17 2:24 PM, Johannes Berg wrote:
> @@ -2300,14 +2332,35 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
>  			  NLMSG_ERROR, payload, 0);
>  	errmsg = nlmsg_data(rep);
>  	errmsg->error = err;
> -	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
> +	memcpy(&errmsg->msg, nlh,
> +	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
> +						 : sizeof(*nlh));
> +

generically this makes userspace parsing more problematic: the parsing
layer may not know if the socket option has been set to precisely know
the size of errmsg->msg and how much data needs to be skipped to get to
the new attributes.

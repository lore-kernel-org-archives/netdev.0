From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH net-next 1/4] net: add event_list to struct net and
 provide utility functions
Date: Tue, 2 Feb 2016 15:58:29 -0800
Message-ID: <CAO7SqHBhw=tXRakKaNPCdXCFdubfYO02GXzn6M8uWwa-dd50Sg@mail.gmail.com>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com>
	<1454365952-10324-2-git-send-email-noureddine@arista.com>
	<alpine.LFD.2.11.1602022147330.2006@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37342 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836AbcBBX6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 18:58:30 -0500
Received: by mail-wm0-f48.google.com with SMTP id l66so46616674wml.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 15:58:30 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1602022147330.2006@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 12:01 PM, Julian Anastasov <ja@ssi.bg> wrote:

>> +#ifdef CONFIG_NET_NS
>> +static inline void net_add_event_list(struct list_head *head, struct net *net)
>> +{
>> +     if (!list_empty(&net->event_list))
>
>         Above check looks inverted, it works may be
> because INIT_LIST_HEAD(&net->event_list) is missing.
>
>> +             list_add_tail(&net->event_list, head);
>> +}
>> +

Thanks for catching this! I ran my benchmark again with the corrected check
and I still get the same benefits with respect to rtnl_lock hold time.

Salam

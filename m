From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: locating the 'tc actions' hook
Date: Sat, 03 Aug 2013 07:49:45 -0400
Message-ID: <51FCEE59.1030402@mojatatu.com>
References: <51F97F4E.5070102@gmail.com> <51FA493C.8080207@mojatatu.com> <51FAECBF.3030704@intel.com> <51FBFE7B.1010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:60391 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab3HCLtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 07:49:51 -0400
Received: by mail-ee0-f45.google.com with SMTP id c50so764195eek.4
        for <netdev@vger.kernel.org>; Sat, 03 Aug 2013 04:49:50 -0700 (PDT)
In-Reply-To: <51FBFE7B.1010602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 13-08-02 02:46 PM, John Fastabend wrote:

> Perhaps another incorrect observation but what protects the tc_actions?
>
> Create a series of actions via 'tc actions' which populates the hash
> table protected by hinfo->lock and also rtnetlink is holding the rtnl
> lock.
>
> Add a filter with index hook to get this action graph attached to a
> filters tcf_exts pointer.
>
> Now for what I think is the race, the classifier will call tcf_exts_exec
> which will call tcf_action_exec() and start walking the actions and
> executing them with the qdisc_lock held.
>
> At the same time tcf_action_destroy() may be called via 'tc actions
> delete' which will only hold the rtnl lock via rtnetlink.
>

One runs in user context and the other in softirq context; so it will
work fine.

cheers,
jamal

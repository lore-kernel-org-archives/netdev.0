From: Ranjit Manomohan <ranjitm@google.com>
Subject: Re: [RESEND] pkt_sched: Control group classifier
Date: Fri, 7 Nov 2008 09:39:30 -0800
Message-ID: <166fe7950811070939v21d49da7kdae19d7649fbce22@mail.gmail.com>
References: <20081106161330.GN20815@postel.suug.ch>
	 <166fe7950811070751j475c9aa6n861bc43a97d1aec5@mail.gmail.com>
	 <20081107170850.GO20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:37663 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbYKGRjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 12:39:35 -0500
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id mA7HdWRh011272
	for <netdev@vger.kernel.org>; Fri, 7 Nov 2008 09:39:33 -0800
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by wpaz33.hot.corp.google.com with ESMTP id mA7HdVph008990
	for <netdev@vger.kernel.org>; Fri, 7 Nov 2008 09:39:31 -0800
Received: by rv-out-0708.google.com with SMTP id c5so1227569rvf.56
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 09:39:31 -0800 (PST)
In-Reply-To: <20081107170850.GO20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2008 at 9:08 AM, Thomas Graf <tgraf@suug.ch> wrote:
> * Ranjit Manomohan <ranjitm@google.com> 2008-11-07 07:51
>> > +static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
>> > +                              struct tcf_result *res)
>> > +{
>> > +       struct cls_cgroup_head *head = tp->root;
>> > +       struct cgroup_cls_state *cs;
>> > +       int ret = 0;
>> > +
>> > +       /*
>> > +        * Due to the nature of the classifier it is required to ignore all
>> > +        * packets originating from softirq context as accessing `current'
>> > +        * would lead to false results.
>> > +        *
>> > +        * This test assumes that all callers of dev_queue_xmit() explicitely
>> > +        * disable bh. Knowing this, it is possible to detect softirq based
>> > +        * calls by looking at the number of nested bh disable calls because
>> > +        * softirqs always disables bh.
>> > +        */
>> > +       if (softirq_count() != SOFTIRQ_OFFSET)
>> > +               return -1;
>> > +
>>
>>     How about caching the cs->classid in the socket here at this point
>> (if there is a mismatch from the current cgroup value)  if we are in
>> process context and using that value if we are in interrupt context.
>> That should help account for the packets in interrupt context and work
>> seamlessly if the task got moved between cgroups or if the cgroup
>> identifier was changed.
>
> I like the idea, the overhead is relatively small and the sk_buff struct
> does not get polluted. There will still be cases where the skb has been
> orphaned and is no longer connected to a socket but that case is pretty
> rare.
>
> Will you work on a follow-up patch?

Tied up with a few things right now, but I can get around to it
sometime next week (if you don't get a chance to implement it before
that)

-Thanks,
Ranjit


>

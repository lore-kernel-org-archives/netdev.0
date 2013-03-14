From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: Re: [PATCH 1/1] Fix dst_neigh_lookup/dst_neigh_lookup_skb return
 value handling bug
Date: Thu, 14 Mar 2013 13:48:58 +0800
Message-ID: <CAABZP2ymK4nrAG6AN2rjxnJ0fiXQh7sUS0SLA=g0LxRVuBmHRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:64107 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab3CNFzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 01:55:15 -0400
Received: by mail-pb0-f52.google.com with SMTP id ma3so1765364pbc.39
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 22:55:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com>  wrote
>>  	neigh = dst_neigh_lookup(ep->dst,
>>  			&ep->com.cm_id->remote_addr.sin_addr.s_addr);
>> +	if (!neigh) {
>> +		pr_err("%s - cannot alloc neigh.\n", __func__);
>> +		err = -ENOMEM;
>> +		goto fail4;

>You don't need to print error messages for OOM, the mm subsystem will
>do.
Thanks for reviewing,  I clone these error messages print from the code
that follows:
   1612         if (!ep->l2t) {
   1613                 pr_err("%s - cannot alloc l2e.\n", __func__);
   1614                 err = -ENOMEM;
   1615                 goto fail4;
   1616         }

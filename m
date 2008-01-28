From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Mon, 28 Jan 2008 09:33:02 +0100
Message-ID: <20080128083302.GA2115@ff.dom.local>
References: <20080127232018.GA2856@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:43927 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbYA1I0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 03:26:13 -0500
Received: by ug-out-1314.google.com with SMTP id z38so956880ugc.16
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 00:26:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080127232018.GA2856@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-01-2008 00:20, Jarek Poplawski wrote:
> Hi, I have a few questions below:
> 
> Julian Anastasov wrote, On 01/26/2008 01:41 PM:
...
>> --- linux-2.6.24/net/ipv4/fib_hash.c_orig	2008-01-25 10:45:06.000000000 +0200
>> +++ linux-2.6.24/net/ipv4/fib_hash.c	2008-01-26 14:11:34.000000000 +0200
>> @@ -434,19 +434,43 @@ static int fn_hash_insert(struct fib_tab
>>  
>>  	if (fa && fa->fa_tos == tos &&
>>  	    fa->fa_info->fib_priority == fi->fib_priority) {

...One more doubt here. Your FIB description doesn't say about this,
and a code at the end of this function, where a new alias is inserted,
doesn't seem to show this too. Are these aliases in the node sorted by
fib_priority too? I mean, isn't it possible here, that we got fa
from fib_node_alias() with right tos but greater fib_priority, but
there is a better match (with right priority) later on the list yet?
(The comment above this reads something else, but I'd be glad if you
could confirm this.)

Regards,
Jarek P. 

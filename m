From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 6/6] tcp_metrics: Use a single hash table for all network namespaces.
Date: Mon, 09 Mar 2015 14:35:29 -0500
Message-ID: <87wq2qx8u6.fsf@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<8761aayqdd.fsf_-_@x220.int.ebiederm.org>
	<1425926828.8261.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43136 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbbCITjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:39:08 -0400
In-Reply-To: <1425926828.8261.7.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 09 Mar 2015 11:47:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2015-03-09 at 13:31 -0500, Eric W. Biederman wrote:
>
>> @@ -1167,17 +1173,22 @@ static void __net_exit tcp_net_metrics_exit(struct net *net)
>>  {
>>  	unsigned int i;
>>  
>> -	for (i = 0; i < (1U << net->ipv4.tcp_metrics_hash_log) ; i++) {
>> +	if (net != &init_net) {
>> +		tcp_metrics_flush_all(net);
>> +		return;
>> +	}
>
> Note this _very_ unlikely (read: not possible) that
> tcp_net_metrics_exit() will ever be called on init_net
>
> So I would remove all this code.

If the line:
	ret = genl_register_family_with_ops(&tcp_metrics_nl_family,
					    tcp_metrics_nl_ops);

fails then this code will be called with net == &init_net.

Eric

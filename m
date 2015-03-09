From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] tcp_metrics: Use a single hash table for
 all network namespaces.
Date: Mon, 09 Mar 2015 13:21:27 -0700
Message-ID: <1425932487.8261.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	 <CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	 <87d25hrv9m.fsf@x220.int.ebiederm.org>
	 <20150219.144929.1003473344851168804.davem@davemloft.net>
	 <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	 <8761aayqdd.fsf_-_@x220.int.ebiederm.org>
	 <1425926828.8261.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87wq2qx8u6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34685 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbbCIUVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 16:21:30 -0400
Received: by iecvy18 with SMTP id vy18so42661452iec.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 13:21:29 -0700 (PDT)
In-Reply-To: <87wq2qx8u6.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 14:35 -0500, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > On Mon, 2015-03-09 at 13:31 -0500, Eric W. Biederman wrote:
> >
> >> @@ -1167,17 +1173,22 @@ static void __net_exit tcp_net_metrics_exit(struct net *net)
> >>  {
> >>  	unsigned int i;
> >>  
> >> -	for (i = 0; i < (1U << net->ipv4.tcp_metrics_hash_log) ; i++) {
> >> +	if (net != &init_net) {
> >> +		tcp_metrics_flush_all(net);
> >> +		return;
> >> +	}
> >
> > Note this _very_ unlikely (read: not possible) that
> > tcp_net_metrics_exit() will ever be called on init_net
> >
> > So I would remove all this code.
> 
> If the line:
> 	ret = genl_register_family_with_ops(&tcp_metrics_nl_family,
> 					    tcp_metrics_nl_ops);
> 
> fails then this code will be called with net == &init_net.


So, what is wrong calling.

tcp_metrics_flush_all(net)

even if net == &init_net ?

The only code needed after the purge is

kvfree(tcp_metrics_hash);

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: Introduce possible_net_t
Date: Wed, 11 Mar 2015 21:37:55 -0700
Message-ID: <1426135075.11398.144.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150311.215553.1544350193194225837.davem@davemloft.net>
	 <1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.232940.1345045254716776224.davem@davemloft.net>
	 <87oany7tha.fsf_-_@x220.int.ebiederm.org>
	 <874mpq7tbf.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	salo@google.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33233 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbCLEiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:38:01 -0400
Received: by iecvj10 with SMTP id vj10so15203889iec.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 21:38:00 -0700 (PDT)
In-Reply-To: <874mpq7tbf.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 23:06 -0500, Eric W. Biederman wrote:
> Having to say
> > #ifdef CONFIG_NET_NS
> > 	struct net *net;
> > #endif
> 
> in structures is a little bit wordy and a little bit error prone.
> 
> Instead it is possible to say:
> > typedef struct {
> > #ifdef CONFIG_NET_NS
> >       struct net *net;
> > #endif
> > } possible_net_t;
> 
> And then in a header say:
> 
> > 	possible_net_t net;
> 
> Which is cleaner and easier to use and easier to test, as the
> possible_net_t is always there no matter what the compile options.
> 
> Further this allows read_pnet and write_pnet to be functions in all
> cases which is better at catching typos.
> 
> This change adds possible_net_t, updates the definitions of read_pnet
> and write_pnet, updates optional struct net * variables that
> write_pnet uses on to have the type possible_net_t, and finally fixes
> up the b0rked users of read_pnet and write_pnet.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> 
> When I was testing this caught all three locations Eric Dumazet needed
> to add write_pnet as compile errors with network namespaces enabled.


Acked-by: Eric Dumazet <edumazet@google.com>

Only concern is the typedef possible_net_t : It seems number of uses
should be rather small, and we probably could use the "struct
possible_net" instead, to please Linus ;)

From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net 3/4 v2] ipvlan: do not use rcu operations for address list
Date: Tue, 31 Mar 2015 11:35:59 -0700
Message-ID: <CAHA+R7O7h0bbWj4mEam7vEmqkCD3a_73j7LT2A_DB3py8idEgA@mail.gmail.com>
References: <cover.1427566140.git.jbenc@redhat.com>
	<ac744df9efb58775461c40e222bd1713b87357a7.1427566140.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37815 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbbCaSf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 14:35:59 -0400
Received: by igcxg11 with SMTP id xg11so25549448igc.0
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 11:35:59 -0700 (PDT)
In-Reply-To: <ac744df9efb58775461c40e222bd1713b87357a7.1427566140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Sorry for being late)

On Sat, Mar 28, 2015 at 11:13 AM, Jiri Benc <jbenc@redhat.com> wrote:
> @@ -640,7 +640,7 @@ static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>                 return;
>
>         ipvlan_ht_addr_del(addr, true);
> -       list_del_rcu(&addr->anode);
> +       list_del(&addr->anode);
>         ipvlan->ipv6cnt--;
>         WARN_ON(ipvlan->ipv6cnt < 0);
>         kfree_rcu(addr, rcu);

But doesn't this mean kfree_rcu() can be replaced by kfree() too?
I noticed ipvlan_ht_addr_del() waits for RCU readers too.

Thanks.

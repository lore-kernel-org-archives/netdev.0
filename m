From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH 1/6 net-next] inet: collapse ipv4/v6 rcv_saddr_equal
 functions into one
Date: Thu, 12 Jan 2017 12:41:33 -0500
Message-ID: <CAEfhGixyDxk6yNCY-FVLAop-VvO0jB1YuOu3i382Y5S40ocwOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>, kernel-team@fb.com
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35331 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdALRlh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 12:41:37 -0500
Received: by mail-lf0-f67.google.com with SMTP id v186so2888134lfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:41:37 -0800 (PST)
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com. [209.85.215.45])
        by smtp.gmail.com with ESMTPSA id s63sm1034376lja.49.2017.01.12.09.41.34
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 09:41:34 -0800 (PST)
Received: by mail-lf0-f45.google.com with SMTP id m78so18641011lfg.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:41:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 3:19 PM, Josef Bacik <jbacik@fb.com> wrote:
> +int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
> +                        bool match_wildcard)
> +{
> +#if IS_ENABLED(CONFIG_IPV6)
> +       if (sk->sk_family == AF_INET6)
Still wrapping my head around this, so take it with a grain of salt,
but it's not obvious to me that sk and sk2 are guaranteed to have the
same family here (or if it even matters).  Especially in the context
of the next patch which removes the bind_conflict callback...  Does
this need to be an OR check for the family of either socket?  Or is it
safe as-is because the first socket passed to this function is always
the existing one and the second one is the possible conflict socket?

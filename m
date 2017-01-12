From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH 1/6 net-next] inet: collapse ipv4/v6 rcv_saddr_equal
 functions into one
Date: Thu, 12 Jan 2017 13:13:59 -0500
Message-ID: <1484244839.3869.0@smtp.office365.com>
References: <CAEfhGixyDxk6yNCY-FVLAop-VvO0jB1YuOu3i382Y5S40ocwOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Tom Herbert" <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33815 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750934AbdALSOb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 13:14:31 -0500
In-Reply-To: <CAEfhGixyDxk6yNCY-FVLAop-VvO0jB1YuOu3i382Y5S40ocwOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 12:41 PM, Craig Gallek <kraigatgoog@gmail.com> 
wrote:
> On Wed, Jan 11, 2017 at 3:19 PM, Josef Bacik <jbacik@fb.com> wrote:
>>  +int inet_rcv_saddr_equal(const struct sock *sk, const struct sock 
>> *sk2,
>>  +                        bool match_wildcard)
>>  +{
>>  +#if IS_ENABLED(CONFIG_IPV6)
>>  +       if (sk->sk_family == AF_INET6)
> Still wrapping my head around this, so take it with a grain of salt,
> but it's not obvious to me that sk and sk2 are guaranteed to have the
> same family here (or if it even matters).  Especially in the context
> of the next patch which removes the bind_conflict callback...  Does
> this need to be an OR check for the family of either socket?  Or is it
> safe as-is because the first socket passed to this function is always
> the existing one and the second one is the possible conflict socket?

It's safe as is, all we care is that sk1 is the INET6 socket.  In the 
compare function we use inet6_rcv_saddr(sk2) which will return NULL if 
it isn't INET6 and then the function handles that case appropriately.  
This stuff is subtle so it's easy to get confused, I always made sure 
to run it on our production boxes to make sure I didn't break something 
;).  Thanks,

Josef

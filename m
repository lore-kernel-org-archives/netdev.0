From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 3/3] ipv6: obsolete cached dst when removing
 them from fib tree
Date: Wed, 18 Oct 2017 22:30:29 +0200
Message-ID: <1508358629.2599.6.camel@redhat.com>
References: <cover.1508261949.git.pabeni@redhat.com>
         <59304478d82e52c817c92d183ef2105f35c17266.1508261949.git.pabeni@redhat.com>
         <CAEA6p_CMZu-ooO4sKXD3=wg8_wcAB+oZbTujJ4hEDQnjPZRNwg@mail.gmail.com>
         <1508270578.2548.22.camel@redhat.com>
         <CAEA6p_AS9c6pOym4t6FGW-bWfU=YmmL96Fc4vMcnDMCc8ywVqg@mail.gmail.com>
         <1508331782.2559.5.camel@redhat.com>
         <CAEA6p_DC7gZnaiKdQv7q3P6DcH31c1ioCzVk5HrapAjQG7hRKg@mail.gmail.com>
         <20171018190513.dtoqpzjfyapo2iie@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Xin Long <lucien.xin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751411AbdJRUad (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 16:30:33 -0400
In-Reply-To: <20171018190513.dtoqpzjfyapo2iie@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-18 at 12:05 -0700, Martin KaFai Lau wrote:
> Another thing (not limited to this case),
> 
> Considering we have a limited size in the exception table now and
> the oldest one will get removed when the table is full,
> do we still need to purge this periodically in gc?

At least in some scenarios we have only a few entries in the exception
table.

> I would like to see the IPv6's gc eventually goes away.
> 
> If we need to expire the pmtu value of a RTF_CACHE rt,
> can dst.expires be checked during the lookup (like what
> ipv4 is doing) and then remove it from the exception table?

Currently the gc also performs validation vs the related neigh for
GATEWAY dst. That looks potentially quite expensive, as we currently
have a per neighbour atomic refcount (e.g. if the same dst is cached on
different CPUs)

Cheers,

Paolo

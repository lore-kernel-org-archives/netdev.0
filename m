From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip6_offload: check segs for NULL in ipv6_gso_segment.
Date: Thu, 01 Dec 2016 07:27:58 -0800
Message-ID: <1480606078.18162.297.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480597564-32355-1-git-send-email-asavkov@redhat.com>
         <1480602847.18162.288.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161201150703.dv463hxgqajqo6pm@shodan.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jstancek@redhat.com,
        steffen.klassert@secunet.com, alexander.h.duyck@intel.com,
        YOSHIFUJI Hideaki /
         =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
        <yoshfuji@linux-ipv6.org>
To: Artem Savkov <asavkov@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201150703.dv463hxgqajqo6pm@shodan.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-01 at 16:07 +0100, Artem Savkov wrote:

> I am not, but this would have the same behavior as pre-07b26c9 code and
> IS_ERR_OR_NULL is used in ipv4's inet_gso_segment().

My concern might have been that IS_ERR_OR_NULL() considers the !ptr to
be unlikely.

But in this code path, we really can not tell.

segs == NULL can be quite likely in TUN case, because of DODGY bit

Commit 50c3a487d50756 replaced the perfectly fine :

if (!segs || IS_ERR(segs))

into dubious

if (IS_ERR_OR_NULL(segs))

segs = NULL is not an error, but use of IS_ERR_OR_NULL() might mislead
programmers trying to understand this code.

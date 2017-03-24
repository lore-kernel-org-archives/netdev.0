From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 5/8] net: Track start of busy loop instead
 of when it should end
Date: Fri, 24 Mar 2017 04:16:50 -0700
Message-ID: <1490354210.9687.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
         <20170323213742.12615.85793.stgit@localhost.localdomain>
         <1490318682.9687.22.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0Ue+UFOAhwxN-EOjWYZa9YZc2QaT5gvoLap70COs0rF7NA@mail.gmail.com>
         <1490329655.9687.33.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UfQPLqHtZ_SjanbLoG6t5f36C4nsORuw6yjLT0xZrEoEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Samudrala, Sridhar" <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgT0UfQPLqHtZ_SjanbLoG6t5f36C4nsORuw6yjLT0xZrEoEQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-23 at 22:55 -0700, Alexander Duyck wrote:

> Right, but time_after assumes roll over.  When you are using a time
> value based off of local_clock() >> 10, you don't ever roll over when
> you do addition.  Just the clock rolls over.  At least on 64 bit
> systems.
> 
> So if local time approaches something like all 1's, and we have
> shifted it by 10 it is then the max it can ever reach is
> 0x003FFFFFFFFFFFFF.  I can add our loop time to that and it won't roll
> over.  In the mean time the busy_loop_us_ can never exceed whatever I
> added to that so we are now locked into a loop.  I realize I am
> probably being pedantic, and it will have an exceedingly small rate of
> occurrence, but it is still an issue.

Do you realize that a 64bit clock wont rollover before the host has
reached 584 years of uptime ?

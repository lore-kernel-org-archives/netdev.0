From: Jes Sorensen <jes@trained-monkey.org>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: 15 Dec 2002 13:31:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3fzszb0cs.fsf@trained-monkey.org>
References: <3DF2844C.F9216283@digeo.com> <20021207.153045.26640406.davem@redhat.com> <3DF28748.186AB31F@digeo.com> <3DF28988.93F268EA@digeo.com>
Cc: "David S. Miller" <davem@redhat.com>, jgarzik@pobox.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: Andrew Morton's message of "Sat, 07 Dec 2002 15:51:36 -0800"
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Andrew" == Andrew Morton <akpm@digeo.com> writes:

Andrew> Andrew Morton wrote:
>> Then I am most confused.  None of these fields will be put under
>> busmastering or anything like that, so what advantage is there in
>> spreading them out?

Andrew> Oh I see what you want - to be able to pick up all the
Andrew> operating fields in a single fetch.

Andrew> That will increase the overall cache footprint though.  I
Andrew> wonder if it's really a net win, over just keeping it small.

There's another case where it matters, I guess one could look at it as
similar to the SMP case, but between CPU and device. Some devices have
producer indices in host memory which they update whenever it
receiving a packet. By putting that seperate from TX data structures
you avoid the CPU and the NIC fighting over cache lines.

Cheers,
Jes

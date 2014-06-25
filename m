From: Tom Herbert <therbert@google.com>
Subject: Re: [GIT] Networking
Date: Tue, 24 Jun 2014 20:51:39 -0700
Message-ID: <CA+mtBx9o3QZJHyzJ8iXR=th5gJBeFkWLR5T-8a_g9CExKKb3nQ@mail.gmail.com>
References: <20140616234254.GA15332@redhat.com>
	<20140623234759.GA19138@redhat.com>
	<CA+55aFx--+YxUWX5SGet0QxfDo2PcJj3x5tcwqiCTA9yiyi_bQ@mail.gmail.com>
	<20140624.172616.757600677169858458.davem@davemloft.net>
	<CA+mtBx8F3XPU5bLfKc046Oz8thp50FZadLfAAfe-Hw2HU9sjsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: torvalds@linux-foundation.org, davej@redhat.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx8F3XPU5bLfKc046Oz8thp50FZadLfAAfe-Hw2HU9sjsA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I believe in the no scatter-gather case of  skb_segment is not set
correctly. Will post a patch momentarily.

On Tue, Jun 24, 2014 at 8:05 PM, Tom Herbert <therbert@google.com> wrote:
>> tcp_gso_segment() makes sure that the headers are reachable in the linear
>> area with the pskb_may_pull(skb, sizeof(*th)) call, and gso_make_checksum()
>> is only working with the area up to SKB_GSO_CB()->csum_start which should
>> be within this area for sure.
>>
> Seems likely that csum_start is not properly initialized in this path.
> I am thinking that this may have happened in GRO path on a checksum
> error where CHECKSUM_PARTIAL (and hence csum) is not set. That would
> explain the infrequency of the occurrence,  and also previously not
> setting csum would have just resulted in sending a corrupted packet
> not a crash.
>
>> Well, that's the precondition we seem to be relying upon, I suppose an
>> assert is in order.
>
> Assert on SKB_GSO_CB()->csum_start == 0 would confirm my suspicion.

From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 13:15:41 -0400
Message-ID: <CAATkVEz9QzYfLhfv6LgGVatPxP3Q1v9DdWaSsFTKgfKrdvQYhw@mail.gmail.com>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
	<51A39A3F.8080903@redhat.com>
	<1369693520.3301.477.camel@edumazet-glaptop>
	<1369715506.2034.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rik van Riel <riel@redhat.com>, atomlin@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	aquini@redhat.com, sergei.shtylyov@cogentembedded.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369715506.2034.30.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 28, 2013 at 12:31 AM, Joe Perches <joe@perches.com> wrote:
>
> I think the __alloc_skb alloc failure message is ok,
> but maybe there shouldn't be something "scary" like
> a dump_stack.
>
> Maybe this site should use a trivial debug error
> message like below instead.

The stack trace may or may not be important for debugging, however
what is important is that we know how often this is happening. That
implies that there should be a percpu counter of allocation failures
here, regardless of a dump_stack, rate limited or not. I would suppose
it's ok for no stack by default as long as there is a counter, for
this specific call only.

There are some scary ways this code is called, for example from
tcp_send_fin(). It does yield() in that loop, but otherwise it just
spins.

-Deb

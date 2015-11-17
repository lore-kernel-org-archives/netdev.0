From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Tue, 17 Nov 2015 03:57:10 +0100
Message-ID: <CAHmME9odyPcXSv5Vc5LCYiMANZKjhZ3+WbNdh8wFmG2BVdkHoA@mail.gmail.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
	<1447712702.2096268.441562113.30345320@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447712702.2096268.441562113.30345320@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 16, 2015 at 11:25 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Have a look at __dev_queue_xmit and the per_cpu recursion limits
> implemented there:
>
>                         if (__this_cpu_read(xmit_recursion) >
>                         RECURSION_LIMIT)
>                                 goto recursion_alert;

Ahh, thanks for pointing that out. So this works with virtual devices
with no queue. As of some recent changes, that now applies to what I'm
doing.

Unfortunately, I get a complete hard crash, with the blinking
keyboard. The only thing written to serial before it dies is:
[  171.347446] Dead loop on virtual device wg0, fix it urgently!
This means it did hit that recursion condition, which is good.
I assume the recursion limit is just too high, and this has something
to do with me overflowing the stack. I'll test this hypothesis and see
if I can add a similar check inside my driver to make it lower. If
this works, I'm satisfied.

Thanks a lot for the pointer here.

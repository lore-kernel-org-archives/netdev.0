From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next PATCH v6 0/3] net: reserve ports for applications using fixed port numbers
Date: Thu, 04 Mar 2010 11:14:07 -0800
Message-ID: <m1vddbdhmo.fsf@fess.ebiederm.org>
References: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
	<20100227.033230.196838696.davem@davemloft.net>
	<4B8F6FF0.5000306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, opurdila@ixiacom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nhorman@tuxdriver.com, eric.dumazet@gmail.com
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B8F6FF0.5000306@redhat.com> (Cong Wang's message of "Thu\, 04 Mar 2010 16\:31\:44 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <amwang@redhat.com> writes:

> David Miller wrote:
>> Eric B., could you look over the first two patches (which touch the
>> sysctl core) and give some review and ACK/NACK?
>>
>
> ping Eric W. Biederman ... :)

I have looked and it is not easy to tell by simple review if
correctness has been maintained in the proc cleanup patch.
Furthermore the code even after the cleanups still feels like code
that is trying too hard to do too much.


I think the example set by bitmap_parse_user in it's user interface is
a good example to follow when constructing bitmap helper functions.
Including having the actual parsing code should live in lib/bitmap.c

The users of bitmap_parse_user do something very nice.  They allocate
a temporary bitmap.  Parse the userspace value into the temporary
bitmap, and then move that new bitmap into the kernel data structures.
For your large bitmap this seems like the idea way to handle it.  That
guarantees no weird intermediate failure states, and really makes the
the bitmap feel like a single value.

I would add the restriction that the values in the list of ranges
always must be increasing, and in general restrict the set of accepted
values as much as possible.  If we don't accept it now we don't have
to worry about some userspace application relying on some unitended
side effect a few years into the future.


I think it is a serious bug that you clear the destination bitmap
in the middle of parsing it.  That will either open or close all
ports in the middle of parsing, and I can't see how that would
ever be a good thing.

Eric

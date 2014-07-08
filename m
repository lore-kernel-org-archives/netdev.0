From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 2/2] netpoll: avoid reference leaks
Date: Tue, 08 Jul 2014 14:17:08 -0700 (PDT)
Message-ID: <20140708.141708.2064358397103630362.davem@davemloft.net>
References: <f98ccbfee35a7ab7f9499ede9b34e6b1120d88f1.1404172155.git.decot@googlers.com>
	<20140707.193505.345276817146527821.davem@davemloft.net>
	<CAG88wWZ9GiqoOscqG4-ePOWo8bXgSTAQ6=6-tZPahMcxOvQMLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, edumazet@google.com, amwang@redhat.com,
	antonio@meshcoding.com, jpirko@redhat.com
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG88wWZ9GiqoOscqG4-ePOWo8bXgSTAQ6=6-tZPahMcxOvQMLg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Tue, 8 Jul 2014 12:35:14 -0700

> Thanks for the feedback. This patch results from manual inspection of
> the code. I agree my commit description is abusive: in the case of
> bonding, I think everything is fine, there should be no ref leak,
> cleanup paths seem clean.
> 
> My point was to make things more predictable: ndo_netpoll_cleanup
> called anyways to acknowledge actual loss of a ref to npinfo,
> irrespective of whether it's the last ref or not. Without this patch,
> calling ndo_netpoll_cleanup would depend on some timing behavior, hard
> to predict, and users of the API have better be careful to reclaim the
> refs manually anyways: as a consequence, not sure this callback is
> actually required in its current inception.

You've increased my confusion rather than decreased it.

You fail to address the core issue in my feedback:

	Whoever drops the refcount to zero must be the one to invoke
	the cleanup function.

Please address this concisely, and directly.

From: Jason Baron <jbaron@akamai.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 22:39:58 -0400
Message-ID: <560C9CFE.6090509@akamai.com>
References: <20150913195354.GA12352@jig.fritz.box>	<20150914023949.GA15012@dcvr.yhbt.net>	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>	<560AE202.4020402@akamai.com> <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/30/2015 01:54 AM, Mathias Krause wrote:
> On 29 September 2015 at 21:09, Jason Baron <jbaron@akamai.com> wrote:
>> However, if we call connect on socket 's', to connect to a new socket 'o2', we
>> drop the reference on the original socket 'o'. Thus, we can now close socket
>> 'o' without unregistering from epoll. Then, when we either close the ep
>> or unregister 'o', we end up with this list corruption. Thus, this is not a
>> race per se, but can be triggered sequentially.
> 
> Sounds profound, but the reproducers calls connect only once per
> socket. So there is no "connect to a new socket", no?
> But w/e, see below.

Yes, but it can be reproduced this way too. It can also happen with a
close() on the remote peer 'o', and a send to 'o' from 's', which the
reproducer can do as pointed out Michal. The patch I sent deals with
both cases.

Thanks,

-Jason

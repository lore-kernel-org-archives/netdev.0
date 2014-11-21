From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Restore RFC5961-compliant behavior for SYN packets
Date: Thu, 20 Nov 2014 18:22:07 -0800
Message-ID: <1416536527.8629.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416524993-26228-1-git-send-email-calvinowens@fb.com>
	 <1416526940.8629.62.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141121014727.GA1536781@mail.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Eric Dumazet <edumazet@google.com>, kernel-team@fb.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141121014727.GA1536781@mail.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-20 at 17:47 -0800, Calvin Owens wrote:

> That's actually not what led to finding this, but it's a good point. :)
> 
> What if the challenge-ACK counter were decremented in tcp_validate_incoming()
> when a valid RST packet is seen? That would allow legitimate remote
> hosts to reestablish connections without being ratelimited, and still
> prevent a malicious host from guessing sequence numbers.
> 
> There would need to be a way to tell if a challenge ACK had in fact been
> sent and only decrement in that case, since otherwise a local attacker
> could establish and immediately reset lots of connections to keep the
> counter below the ratelimit threshold and guess sequence numbers.
> 
> Simply adding a flag to struct tcp_sock would work: just set the flag
> whenever a challenge ACK is sent, and clear it and decrement the counter
> only if it is set when a valid RST packet is seen.

Seems tricky, a Challenge ACK do not necessarily gives an RST.

Anyway this certainly can wait, as we already have a sysctl to
eventually work around the issue.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !

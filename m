From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: packet_sendmsg_spkt sleeping from invalid context
Date: Mon, 14 Dec 2009 22:30:04 +0100
Message-ID: <20091214213002.GA5203@nowhere>
References: <20091214175211.GA5102@nowhere> <4B2690E7.4030303@gmail.com> <20091214205231.GB5037@nowhere> <4B26AD65.1020004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932827AbZLNVaP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B26AD65.1020004@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 14, 2009 at 10:25:57PM +0100, Eric Dumazet wrote:
> Le 14/12/2009 21:52, Frederic Weisbecker a =E9crit :
> >=20
> > I also wonder. Are you using PREEMPT_RCU ?
>=20
> Not at all :)
>=20
> But yes, this is illegal to do the memcpy_fromiovec() in rcu_read_loc=
k() context.


I've just tested, and with rcu preempt it is mute, no warning :)


> > That may explain why you haven't seen this issue because
> > might_sleep() doesn't see you are in a rcu read locked
> > section as preemption is not disabled, but it is illegal to
> > voluntarily sleep in such area (although it's fine with
> > preempt rcu) as doing so with non-prempt RCU config would barf.
> >=20
> > I'm trying a patch to handle that.
>=20
> As you want, I also have a patch testing right now :)


But mine is to teach might_sleep() to handle rcu preempt case,
not to fix this net dev thing.

But I'll happily test the fix you have :)

Thanks.

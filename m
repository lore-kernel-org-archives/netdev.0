From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Thu, 21 Jun 2012 22:27:49 +0200
Message-ID: <1340310469.4604.6702.camel@edumazet-glaptop>
References: <CAATkVEzTxT6d5nzt_qwCuFWM-WcN8hdhjGxFRPXJ4=L35wKbGw@mail.gmail.com>
	 <4FE37783.9000409@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	Debabrata Banerjee <dbavatar@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Josh Hunt <johunt@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FE37783.9000409@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-21 at 14:35 -0500, Josh Hunt wrote:

> Can anyone provide details of the crash which was intended to be fixed
> by 2bec5a369ee79576a3eea2c23863325089785a2c? With this patch in and
> doing concurrent adds/deletes and dumping the table via netlink causes
> duplicate entries to be reported. Reverting this patch causes those
> problems to go away. We can provide a more detailed test if that is
> needed, but so far our testing has been unable to reproduce the crash
> mentioned in the above commit with it reverted.

A mere revert wont be enough.

Looking at this code, it lacks proper synchronization
between tree updaters and tree walkers.

fib6_walker_lock rwlock is not enough to prevent races.

Are you willing to fix this yourself ?

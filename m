From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 17:54:03 +0200
Message-ID: <1342022043.3265.8179.camel@edumazet-glaptop>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
	<1342019518.3265.8116.camel@edumazet-glaptop>
	<4FFD98EA.1040301@candelatech.com>
	<1342020306.3265.8129.camel@edumazet-glaptop>
	<4FFD9F18.6030401@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, mattmathis@google.com,
	codel@lists.bufferbloat.net, ncardwell@google.com,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <4FFD9F18.6030401@candelatech.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Wed, 2012-07-11 at 08:43 -0700, Ben Greear wrote:
> On 07/11/2012 08:25 AM, Eric Dumazet wrote:
> > On Wed, 2012-07-11 at 08:16 -0700, Ben Greear wrote:
> >
> >> I haven't read your patch in detail, but I was wondering if this feature
> >> would cause trouble for applications that are servicing many sockets at once
> >> and so might take several ms between handling each individual socket.
> >>
> >
> > Well, this patch has no impact for such applications. In fact their
> > send()/write() will return to userland faster than before (for very
> > large send())
> 
> Maybe I'm just confused.  Is your patch just mucking with
> the queues below the tcp xmit queues?  From the patch description
> I was thinking you were somehow directly limiting the TCP xmit
> queues...
> 

I dont limit tcp xmit queues. I might avoid excessive autotuning.



> If you are just draining the tcp xmit queues on a new/faster
> trigger, then I see no problem with that, and no need for
> a per-socket control.

Thats the plan : limiting numer of bytes in Qdisc, not number of bytes
in socket write queue.

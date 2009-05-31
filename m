From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 19:40:16 -0400
Message-ID: <1243813216.3966.254.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090531195557.GA2777-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-05-31 at 21:55 +0200, Jarek Poplawski wrote:

> But then, there could be "tc filter replace" with only this
> (n->nlmsg_type == RTM_NEWTFILTER && (n->nlmsg_flags&(NLM_F_CREATE)))
> which can't get here with a newly created tp, I guess.

Right - because in that case tp would already exist and would
be found in the lookup.

> I'm almost sure these commands (right or wrong) can trigger such a 
> leak:
> 
> $ sudo tc qdisc add dev lo root handle 1: htb
> $ sudo tc filter add dev lo proto ip pref 1 handle 800::1 u32 match
u32 0 0 classid 1:1
> $ sudo tc filter add dev lo proto ip pref 2 handle 800::1 u32 match
u32 0 0 classid 1:1
> RTNETLINK answers: File exists

You are good - A tip of my hat and a wag of my finger at you;->
Ok, now i looked a lot closer at all 8 classifiers
and u32 is the only one that can fault. It just needs to be fixed.
I will wait until Minoru's patch and then i will submit a fix for it.
Of course the commands from user space are a little rude ;->

cheers,
jamal

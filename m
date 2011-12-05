From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: Integration of Open vSwitch
Date: Mon, 05 Dec 2011 08:49:03 -0500
Message-ID: <1323092943.1831.19.camel@mojatatu>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
	<1322658716.2243.12.camel@mojatatu>
	<CAEP_g=8UM17Jbv2Y7ag7kO7BuXENDiitKydXMjiNtB+-uyxvKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8UM17Jbv2Y7ag7kO7BuXENDiitKydXMjiNtB+-uyxvKQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Jesse,

I empathize with effort youve put in, i really do; youve
already created the messaging from user space to kernel
and dammit it works; however, i  dont agree with your reasoning. 
The classifier action code is _exactly_ the same infrastructure.
The user space API/messaging already exists. If there are actions
or a classifier missing - add it.
I wish i had the time to re-write the pieces i think need
changing. If the plan is to migrate to the current tc action
code, I will be fine with it - but you are not even suggesting
that.

I think i will punt this to DaveM to make the call.

cheers,
jamal

On Fri, 2011-12-02 at 15:30 -0800, Jesse Gross wrote:

> 
> I completely agree with the desire to share code where there's overlap
> and it makes sense (I was actually just working on some refactoring to
> increase code reuse before this).
> 
> I think one of the key things to focus on is the userspace/kernel
> interface since we'll have much less opportunity to significantly
> change that over time.  Getting both compatibility and performance is
> something that we've worked on a fair amount and have arrived at a
> solution that meets the needs of OVS (and probably only OVS) pretty
> well.  I think it's a nice model but keeping that while refactoring on
> top of the tc layer seems challenging to do cleanly because the flow
> information is needed by both the flow lookup and userspace
> communication.  Stringing that through generic code seems fairly
> unappealing.
>
> So I agree with you in principle and if you are right that things tend
> to converge there should be more room for code reuse over time.  Right
> now though I would just focus on the high level bits.

From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: tun.c patch to fix "smp_processor_id() in preemptible code"
Date: Tue, 19 Oct 2004 14:31:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098210711.2148.69.camel@krustophenia.net>
References: <1097876587.4170.16.camel@marvin.home.parkautomat.net>
	 <1097879702.6737.7.camel@krustophenia.net>
	 <200410172314.38597.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200410172314.38597.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-10-17 at 16:14, Denis Vlasenko wrote:
> > Your patch:
> > 
> > +       preempt_disable();
> >         netif_rx_ni(skb);
> > +       preempt_enable();
> > 
> > just wraps this code in preempt_disable/enable:
> > 
> > static inline int netif_rx_ni(struct sk_buff *skb)
> > {
> >        int err = netif_rx(skb);
> >        if (softirq_pending(smp_processor_id()))
> >                do_softirq();
> >        return err;
> > }
> > 
> > Isn't this considered an incorrect use of preempt_disable/enable?  My
> > reasoning is that if this was correct we would see preempt_dis/enable
> > sprinkled all over the code which it isn't.
> > 
> > Why do you have to call do_softirq like that?  I was under the
> > impression that you raise a softirq and it gets run later.
> 
> There is a possibility that this guy just wanted to fix his
> small problem.
> 

Yes, that is what I thought.  The question was more directed at the
list.  I added netdev to the cc:.  

I looked at Robert Love's book and I am still unclear on the use of
do_softirq above.  To reiterate the question:  why does netif_rx_ni have
to manually flush any pending softirqs on the current proccessor after
doing the rx?  Is this just a performance hack?

Lee

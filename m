From: satya srikanth <satyasrikanth2001@yahoo.com>
Subject: Re: gigabit ethernet
Date: Fri, 13 Feb 2004 02:38:18 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213103818.55540.qmail@web21110.mail.yahoo.com>
References: <402B48A8.3060800@caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
In-Reply-To: <402B48A8.3060800@caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Sir,
    Thanks a lot for the reply.
    I have checked the CPU utilization. Its averaging
around 50% and reaching 100% and some instances. I
have also looked at the intel's document. First of all
I could not understand why all my softirqs are going
only to cpu0 when I have multiple processors. When I
used 2.4.18- kernel, I didnt face this problem. Now I
am using 2.4.20-8 smp. Intel says that e1000 does not
use NAPI by default. But, I dont know why cpu0 is
handling all softirqs while other processors are
sitting idle.
    Also I found that number of interrupts are
reasonable but number of packets per interrupt is
averaging around 40 in my case. As my cpu is not able
to handle all these in 1 jiffy(time_squeeze), I am
reaching throttle count and thus drops. When I changed
netdev_max_backlog to 300000 and rmem_default to
300000000 then I am able to handle all packets
received by interface. Is it OK to have such a high
values?
    My round trip propagation delay is <0.2 ms. But I
could not understand how it would affect the
performance. Please throw some light on this. 
    
regards,
Satya
  
--- "Xiaoliang (David) Wei" <weixl@caltech.edu> wrote:
> Hi Satya,
> 
>       Did you check the CPU utilization? If you use
> smaller packet size, 
> the interrupt rate may be a problem.
>       You can modulate the NIC's interrupt rate. See
> the document for 
> details:
>
http://www.intel.com/support/network/adapter/1000/e1000.htm#parameters
> 
> 
>       Also, I assume the round trip propagation
> delay for your 
> connections is very small (such as <10ms)?
> 
> 
> -David
> 
> satya srikanth wrote:
> > Sir,
> >     I need some help from you. I am using 2 xeon(2
> > GHz) machines each with two processors running
> linux
> > 2.4.20-8smp kernel and having intel PRO/1000
> gigabit
> > adapter NIC card(e1000 driver). I tried connecting
> > both of them using a gigabit switch. I am getting
> > gigabit speed only if I use my own TCP sockets
> sending
> > packets of size around 1400 bytes. If I send
> packets
> > of size around 500 bytes, I am getting maximum of
> only
> > 500 Mbps. I noticed that NIC is receiving all the
> > packets but they are getting dropped in the
> kernel.
> >         I tried changing the settings like
> > netdev_max_backlog to 30000 and rmem_max, wmem_max
> and
> > txqueuelen, but of no use. Can you please suggest
> some
> > changes that I need to make to achieve this speed.
> > (Like changing number of Rx interrupts, Tx
> interrupts
> > etc). Can you please suggest some other links
> where I
> > can get some useful information. Will linux router
> > project LRP help me to achieve it.
> > 
> >         with regards,
> >         Satya Srikanth.
> > 
> 
> 
> -- 
>
------------------------------------------------------
> Xiaoliang (David) Wei   Graduate Student of
> CS@Caltech
> WWW: http://www.cs.caltech.edu/~weixl
>
======================================================
> 
> 


__________________________________
Do you Yahoo!?
Yahoo! Finance: Get your refund fast by filing online.
http://taxes.yahoo.com/filing.html

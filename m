From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: 2.6.10 and HTB dequeue bug
Date: Wed, 02 Mar 2005 00:45:51 +0100
Message-ID: <4224FEAF.2090209@tpack.net>
References: <200503011403.07243.akohlsmith@mixdown.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Andrew Kohlsmith <akohlsmith@mixdown.ca>
In-Reply-To: <200503011403.07243.akohlsmith@mixdown.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Kohlsmith wrote:
> I received the following in my dmesg today.  As requested by tgr in FreeNode's 
> #lartc, I'm emailing all the requested information here.

> HTB: dequeue bug (8,123376738,123376738), report it please !
> htb*g j=123376738 lj=123376738
> htb*r7 m=0
> htb*r6 m=0
> htb*r5 m=0
> htb*r4 m=0
> htb*r3 m=0
> htb*r2 m=0
> htb*r1 m=0
> htb*r0 m=0
> htb*c10001 m=2 t=24731 c=24731 pq=0 df=68181 ql=0 pa=0 f:
> htb*c10010 m=2 t=291481 c=28542 pq=0 df=68181 ql=0 pa=0 f:
> htb*c10020 m=2 t=77441 c=28542 pq=0 df=203144 ql=0 pa=0 f:
> htb*c10030 m=2 t=-91376 c=-2715 pq=0 df=92920 ql=0 pa=0 f:
> htb*c10040 m=2 t=303504 c=28402 pq=0 df=4498679 ql=0 pa=0 f:
> htb*c10050 m=2 t=283166 c=26595 pq=0 df=859108 ql=0 pa=0 f:

An overflow of q->direct_queue (in htb_enqueue) seems to offset sch->q.qlen.
Probably this is what's causing htb_dequeue to complain.

-Tommy

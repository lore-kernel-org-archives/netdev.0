From: "David S. Miller" <davem@redhat.com>
Subject: Re: bk16 changes to cbq
Date: Sat, 3 Jul 2004 10:16:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703101646.52ae1e01.davem@redhat.com>
References: <1088861810.1039.298.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088861810.1039.298.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 03 Jul 2004 09:36:50 -0400
jamal <hadi@cyberus.ca> wrote:

> -               if (q->wd_expires && !netif_queue_stopped(sch->dev)) {
> +               if (q->wd_expires) {
>                         long delay = PSCHED_US2JIFFIE(q->wd_expires);
>                         if (delay <= 0)
>                                 delay = 1;
> 
> What i remember is this (4-5 years back) used to cure a bug - cant
> remember the details unfortunately, but Alexey may remember.
> I am hoping removal of the above line implies that those conditions dont
> exist anymore? 

The test is racy with drivers, on the very next line the
driver could take a TX completion interrupt and unplug the
queue invalidating the test entirely.

If the test proves wrong, that's OK because we'll try again
at the top level of packet queue dispatch.

There was a good explaination of Stephen's patch
on netdev when he posted it.

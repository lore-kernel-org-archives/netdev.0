From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Re: [Ipsec-tools-devel] Re: IPSEC: on behavior of acquire
Date: Sat, 2 Apr 2005 15:25:53 +0300
Message-ID: <20050402122553.GA7521@gemtek.lt>
References: <1112405303.1096.37.camel@jzny.localdomain> <424E454D.4090402@gmc.lt>
Reply-To: Zilvinas Valinskas <zilvinas@gemtek.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, ipsec-tools-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
Content-Disposition: inline
In-Reply-To: <424E454D.4090402@gmc.lt>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 02, 2005 at 10:10:05AM +0300, Aidas Kasparas wrote:
> 
> 
> jamal wrote:
> >test1)on one window run setkey -x:
> >
> >ping -c 1 someDST
> >
> >-1) packet arrives towards outbound
> >0) Larval state created
> >1) one acquire sent.
> >2) timeout.
> >3) packet dropped. -ESRCH returned.
> >4) larval state deleted
> >
> >So question 1): Shouldnt the return code be -ERESTART to ask
> >the app to retry?
> >question 2) Why is there a hardcoding of 1 try only?
> 
> Re 1 try only. There is little sense to do more tries. If there is no 
> deamon listening to pfkey messages, then no connection will be made no 
> matter how many retries you'll do. If deamon/link/peer is slow and SA 
> was not established before timeout expired, then repeated acquire will 
> be simply ignored (deamon will find out that negotiation is already in 
> progress, there is no reason to start another negotiation and therefore 
> will drop that acquire request). And the only situation where repeated 
> acquires may help is when pfkey messages are lost. But pfkey was not 
> designed to survive message loses, therefore you should not operate your 
> boxes in mode when lost pfkey messages are a rule, not an exception. And 
> on the other hand, occasional pfkey message loses can be worked around 
> by applications/user retry.
> 
> Re error code returned. Error codes returned by pfkey never were 
> perfect. But your experiment is not perfect too. You sent pings with no 
> KE deamon running. pfkey code found that there is nothing receiving 
> acquire messages => there is no chance that any process will setup 
> required SAs and tried to inform about that (I agree, return code is not 
> very informative, at least until you learn about reasons why it is 
> such). If you would have racoon (or other pfkey based ISAKMP daemon) 
> running, you would get "resource temporarily unavailable" (don't know 
> which error code corresponds to that message), which IMHO is ok (if it 
> is not, please explain).

EBUSY I think it is.

I am not entirely sure it is ok to return such error, some applications are
not coping nicely with it. Perhaps ECONNREFUSED is more reasonable - as it 
doesn't brake old apps assumption (connection cannot be established,
doesn't matter if that is due to routing or IPsec SPD or anything else).
Although it is quite simple to fix applications to handle EBUSY and retry ...

I thought it was annoying that applications quit because of EBUSY - when
I had tried IPsec first time. Now I think it is quite handy - especially
from scripts, I am sure that if something goes wrong - ping (or other
application) won't block ...

> 
> Re netlink behaviour I can not comment as I don't use it for ipsec 
> purposes, but would like to read similar explanation. Reason for that - 
> idea that ipsec-tools one day could support operation via netlink is not 
> ruled out of our minds. Yet, afaik nobody is working on it at the moment.
> 
> 
> -- 
> Aidas Kasparas
> IT administrator
> GM Consult Group, UAB
> 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> Ipsec-tools-devel mailing list
> Ipsec-tools-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel

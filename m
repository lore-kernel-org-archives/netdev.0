From: jamal <hadi@cyberus.ca>
Subject: Re: IPSEC: on behavior of acquire
Date: 02 Apr 2005 16:28:46 -0500
Message-ID: <1112477326.1088.321.camel@jzny.localdomain>
References: <1112405303.1096.37.camel@jzny.localdomain>
	 <424E454D.4090402@gmc.lt>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <424E454D.4090402@gmc.lt>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-02 at 02:10, Aidas Kasparas wrote:

> 
> Re 1 try only. There is little sense to do more tries. If there is no 
> deamon listening to pfkey messages, then no connection will be made no 
> matter how many retries you'll do. If deamon/link/peer is slow and SA 
> was not established before timeout expired, then repeated acquire will 
> be simply ignored (deamon will find out that negotiation is already in 
> progress, there is no reason to start another negotiation and therefore 
> will drop that acquire request). And the only situation where repeated 
> acquires may help is when pfkey messages are lost. 

Exactly what i was trying to emulate - lost messages. I would expect it
to be the rule to loose messages - but given theres no guarantee of
delivery, messages could be lost.

> But pfkey was not 
> designed to survive message loses, therefore you should not operate your 
> boxes in mode when lost pfkey messages are a rule, not an exception. And 
> on the other hand, occasional pfkey message loses can be worked around 
> by applications/user retry.
> 

I think its more than just pfkey (or netlink) - rather the ipsec
framework itself.

One could look at the acquire as part of the "connection" setup
(for lack of better description). Without the acquire succeeding, theres
no connection..(assuming that to be a policy).
Therefore if acquire is not supposed to be delivered with some certainty
(read: retries) then theres some resiliciency issues IMO.
 
Note: Sometimes theres no app. Example a packet coming into a gateway.

> Re error code returned. Error codes returned by pfkey never were 
> perfect. But your experiment is not perfect too. You sent pings with no 
> KE deamon running.

Note what my goals were.

>  pfkey code found that there is nothing receiving 
> acquire messages => there is no chance that any process will setup 
> required SAs and tried to inform about that (I agree, return code is not 
> very informative, at least until you learn about reasons why it is 
> such). If you would have racoon (or other pfkey based ISAKMP daemon) 
> running, you would get "resource temporarily unavailable" (don't know 
> which error code corresponds to that message), which IMHO is ok (if it 
> is not, please explain).
> 

Havent tried that - the reason i said restart was the right signal was
mainly that an app could translate that to mean "try again".
In other words even in the case of ping -c1 the ping app could have 
reattempted.

On Sat, 2005-04-02 at 07:25, Zilvinas Valinskas wrote:
> EBUSY I think it is.
> 
> I am not entirely sure it is ok to return such error, some applications are
> not coping nicely with it. Perhaps ECONNREFUSED is more reasonable - as it 
> doesn't brake old apps assumption (connection cannot be established,
> doesn't matter if that is due to routing or IPsec SPD or anything else).
> 

What about ERESTART the way netlink does it right now?
ECONNREFUSED is probably not a bad idea.
ping was clearly dumb and didnt do anything with the info.
Overall, I think the errors are unfortunately not descriptive at all.

cheers,
jamal

From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: [Ipsec-tools-devel] Re: IPSEC: on behavior of acquire
Date: Mon, 04 Apr 2005 17:20:59 +0300
Message-ID: <42514D4B.1040202@gmc.lt>
References: <1112405303.1096.37.camel@jzny.localdomain>	 <424E454D.4090402@gmc.lt> <1112477326.1088.321.camel@jzny.localdomain>	 <424FA946.70809@gmc.lt> <1112538566.1096.391.camel@jzny.localdomain>	 <425067D9.9050603@gmc.lt> <1112618007.1096.465.camel@jzny.localdomain>	 <42513A2F.7020504@gmc.lt> <1112620159.1087.486.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112620159.1087.486.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



jamal wrote:
> On Mon, 2005-04-04 at 08:59, Aidas Kasparas wrote:
> 
>>jamal wrote:
>>
>>>I think i have made a bad case of explaining.
>>>Yes, I know where acquires terminate. However this is not about where
>>>acquires terminate. It is insufficient to assume that a succesful
>>>acquire to user space equates to successful interaction to the KE server
>>>which will do an update.
>>
>>Why?
> 
> 
> The reason the kernel sends an acquire is to update larval SAs it
> created. The result is either updating the SA or a rejection for that
> matter. Else theres failure in communication.
> 
> Anology: If you are trying to send a message from one end system
> to another and there are multiple hops between them, then just because
> it made it to the first hop does not equate it made it to its final
> destination. To make it to the final destination, the confirmation has
> to come from the target end.
> So if you said the KE was the final destination then kernel to user
> space was the first hop.
> I am not sure if this is clear as an analogy.

OK, if you have a chain with sevaral hops, then probably there is no 
better way than signal from other end that it got something. The thing 
we do not agree is how this should be managed and supervised.

I would like to provide an analogy too. You have a telenet application. 
You try to connect to some host:port. Your telnet application just makes 
connect(2) syscall and do not cares how kernel establishes that 
connection. What MAC address to send packet to, how and when to 
retransmit syn packet if the ack was not received in timely fashion, and 
so on, so on, so on. If kernel does his job fine, then we have connected 
socket on which to communicate further. If it does not, or there are 
some problems on the target host or network in between, then we will not 
have that connected socket - syscall will return an error.

With ipsec system the situation is quite similar, just kernel and 
userspace have swaped places. Kernel told the userspace to update larval 
SA. Userspace works on that. If it has negotiated keys for that SA with 
KE at remote site, fine, userspace will update SA. If there are 
problems, and key negotiation is not possible -- these SA will not get 
updated and eventually will die. But single signal to userspace is 
sufficient for that process to be performed. Yes, kernel can check state 
of SA every time some packet has to use that SA. But to make noise by 
asking "please negotiate the SA which you're supposed to be negotiating 
already"  ... IMHO it is contrproductive.


-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB

From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Fri, 27 Sep 2002 08:40:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D947BDB.2010007@candelatech.com>
References: <200209271501.TAA21079@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>I have a question though:  If this method is ever called to send an RST,
>>will it work?
> 
> 
> Work for what? This method is used when you have no socket in the system
> matching to this skb. :-)
> 
> 
>>What about this part, do you think it is not needed either?  It appeared
>>to me that w/out this, the sending socket and the receiving socket
> 
> ...
> 
>>sending one, unfortunately).
> 
> 
> No, this is impossible. addrs/ports identity identifies socket unambiguously.

Assume we are sending to ourself, and we bind to the local ip/port before we connect:
we have source IP = 1.2.3.4, source-port = 7

Assume we are connecting to a socket on a second interface, with dest ip = 1.2.3.5,
dest-port = 7

When the SYN is received on the second port after connect() is called, the code
looks for a socket based on source ip 1.2.3.4 and source port 7.  In this case, it should
not find any socket because this SYN is the first communication....

However, because the sender is on the same machine, using the same kernel
structures, the socket **DOES** exist, and so the hash lookup finds it.  At
this point, I believe it sends the RST because a socket in the SYN-sent state
just received a SYN packet, which is not how things should work.

> 
> But even this does not matter, your patch is noop by much simpler pure
> "syntactical" reason, it copies req->bound_dev_if from listening socket.
> And after this the check in lookup req degenerates to TRUE __identitically__.
>  :-)

It will not match the case where the sending socket is bound to interface 3
and the listening socket is bound on interface 4, but both sockets have the
same source IP and port.  That was what I was trying
to do...but I may have not done it quite right :)

Thanks,
Ben

> 
> Alexey
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

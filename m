From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 01:08:17 -0600
Message-ID: <507FAAE1.6000903@genband.com>
References: <507F38D4.102@genband.com> <1350540348.26103.1015.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:44896 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab2JRHJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 03:09:09 -0400
In-Reply-To: <1350540348.26103.1015.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2012 12:05 AM, Eric Dumazet wrote:
> On Wed, 2012-10-17 at 17:01 -0600, Chris Friesen wrote:

>> I'm seeing some unexpected (to me, at least) behaviour with local TCP
>> connections.  The scenario goes as follows:
>>
>> 1) create new IP address and assign to eth device
>> 2) TCP server starts listening on that IP address
>> 3) TCP client connects to server
>> 4) remove new IP address
>> 5) kill server with ctrl-C.  At this point it appears that because the
>> address was removed the shutdown message isn't processed properly.
>> netstat shows the server socket as FIN_WAIT1, but the client socket is
>> still ESTABLISHED.
>> 6) client writes to the connected socket (this passes with no error)
>> 7) client waits for response from server, and waits forever or until
>> keepalive expires

>> It seems like the waiting forever behaviour in step 7 might be
>> legitimate since the address was removed before shutting down the
>> server, but it also seems like we should be able to do better given that
>> everything is local.  In the "remove IP address" case maybe step 6
>> should cause some sort of error since the IP address no longer exists?
>>
>> Incidentally, if we do this sort of scenario with the client and server
>> on different hosts then we get a "no route to host" error at step 6.

>
> I see no real problem here.
>
> Its like you cut the cable somewhere in the path.
>
> Only timeouts will apply.

While I agree generally, it's a bit unfortunate that we can't (as a 
quality of implementation thing) give an earlier notice of failure since 
the kernel knows about both ends of the connection even though the IP 
address is gone.  On the other hand, I imagine that would mean 
special-casing things and presumably that would open a whole can of worms.

Thanks for the reply,

Chris

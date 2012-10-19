From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Fri, 19 Oct 2012 09:12:32 -0600
Message-ID: <50816DE0.4070700@genband.com>
References: <507F38D4.102@genband.com>	 <1350540348.26103.1015.camel@edumazet-glaptop>	 <507FAAE1.6000903@genband.com> <1350545382.26103.1103.camel@edumazet-glaptop>
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
Received: from exprod7og127.obsmtp.com ([64.18.2.210]:53521 "EHLO
	exprod7og127.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab2JSPNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 11:13:18 -0400
In-Reply-To: <1350545382.26103.1103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2012 01:29 AM, Eric Dumazet wrote:
> On Thu, 2012-10-18 at 01:08 -0600, Chris Friesen wrote:
>
>>
>> While I agree generally, it's a bit unfortunate that we can't (as a
>> quality of implementation thing) give an earlier notice of failure since
>> the kernel knows about both ends of the connection even though the IP
>> address is gone.  On the other hand, I imagine that would mean
>> special-casing things and presumably that would open a whole can of worms.
>
> Really what is the difference between a cable cut and what you are
> doing ?
>
> Some frames are lost (Dropped), and sender doesnt 'know' that is
> definitive or temporary failure.
>
> If you want faster response, you need to send RST messages, not dropping
> frames.

After thinking about it for a while, I think you're right.  Initially I 
was expecting that since we know the server side has been taken down we 
should be able to kill the client side, but then I considered the case 
where some sort of of high availability system may have moved the server 
to another host.

> So change your strategy, and add an iptables rule for example ?

That's a good suggestion.  I'll pass it on.

Thanks,
Chris

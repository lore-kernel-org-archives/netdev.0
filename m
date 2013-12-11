From: Christian Grothoff <grothoff@in.tum.de>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Wed, 11 Dec 2013 21:39:42 +0100
Message-ID: <52A8CD8E.8020201@in.tum.de>
References: <52A75EF8.3010308@in.tum.de> <20131211.150137.368953964178408437.davem@davemloft.net> <52A8C8B4.4060109@in.tum.de> <20131211122637.75b09074@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org, jacob@appelbaum.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131211122637.75b09074@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2013 09:26 PM, Stephen Hemminger wrote:
> On Wed, 11 Dec 2013 21:19:00 +0100
> Christian Grothoff <grothoff@in.tum.de> wrote:
> 
>> On 12/11/2013 09:01 PM, David Miller wrote:
>>> From: Christian Grothoff <grothoff@in.tum.de>
>>> Date: Tue, 10 Dec 2013 19:35:36 +0100
>>>
>>>> Only NAT implementations that change the SQN are not supported
>>>> (those should be rare, but we have no hard data on this).
>>>
>>> Even Linux's netfilter can and does do this, it is absolutely necessary
>>> for tracking SIP and FTP protocols, and it's also used in our virtual
>>> server load balancing modules.
>>>
>>
>> We're aware that Linux _can_ do this.  I was not aware it was doing this
>> for
>> SIP and FTP specifically; regardless, what implementations can do is less
>> important than what they are configured to do most of the time, and that's
>> what we'd need hard data on.  Anyway, I'd be very interested to learn how
>> you use this for SIP/FTP to evaluate the impact.  Do you have documentation
>> on this?
>>
>> As for server load balancing, I suspect that those are not the kinds of
>> services that one would typically use port knocking for.  Still, again a
>> good hint as to where trouble might lurk (and we will definitively include
>> those points in the next revision of the documentation).
> 
> The point is that doing it outside of TCP core is safer, less error prone
> and more flexible.
> 

I'm not sure how you drew that conclusion from what I or David said.
Outside of TCP core doesn't fix the NAT issues at all, having a
dozen user-space implementations with configuration quirks doesn't
really sound less error prone to me, and finally I do not even see
a reasonably sane way of doing the TCP payload authentication in
userspace (even writing a process that relays data won't work, as
then you'd loose the source address for the server process).  So
I'd go as far as saying that some of what we do cannot really be
done in userspace.  Now, maybe you mean something other than
"userspace" with "outside of TCP core", in which case I again totally
fail to relate this to what was said here before.

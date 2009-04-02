From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 14:48:11 +0300
Message-ID: <49D4A5FB.1020601@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D49986.3060303@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D49986.3060303@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:

  

>> There is no choice.  Exiting from the guest to the kernel to userspace
>> is prohibitively expensive, you can't do that on every packet.
>>
>>     
>
> Now you are making my point ;)  This is part of the cost of your
> signaling path, and it directly adds to your latency time.   

It adds a microsecond.  The kvm overhead of putting things in userspace 
is low enough, I don't know why people keep mentioning it.  The problem 
is the kernel/user networking interfaces.

> You can't
> buffer packets here if the guest is only going to send one and wait for
> a response and expect that to perform well.  And this is precisely what
> drove me to look at avoiding going back to userspace in the first place.
>   

We're not buffering any packets.  What we lack is a way to tell the 
guest that we're done processing all packets in the ring (IOW, re-enable 
notifications).

-- 
error compiling committee.c: too many arguments to function


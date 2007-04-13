From: Jamie webb <j@jwebb.sygneca.com>
Subject: Re: PROBLEM: tg3 spitting out uninitialized memory
Date: Fri, 13 Apr 2007 18:51:40 +0100
Message-ID: <461FC32C.4060309@jwebb.sygneca.com>
References: <461D57E9.3000300@jwebb.sygneca.com> <p73tzvl7ilg.fsf@bingen.suse.de> <1176410380.11425.5.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.sygneca.com ([83.142.230.29]:45418 "EHLO
	mx2.sygneca.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbXDMRvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 13:51:45 -0400
In-Reply-To: <1176410380.11425.5.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Thu, 2007-04-12 at 16:50 +0200, Andi Kleen wrote:
>> Jamie webb <j@jwebb.sygneca.com> writes:
>>
>>> Hi there
>>>
>>> I have a Dell PE860 with built-in BCM5721, which is reported as
>>> working fine with the tg3 driver, however I have been getting sporadic
>>> data corruption, mostly evident as SSH MAC errors.
>> FWIW i also saw this (data corruption with tg3) occasionally,
>> but never repeatable or with a packet dump.
>>
> My suggestion is to try turning tx checksum off (ethtool -K eth0 tx off)
> to see if it makes a difference.  I'm not aware of checksum problem on
> 5721, but it is worth trying.  See if the other end is reporting TCP
> checksum errors also.

Well, so far so good. I'll let you know if it happens again, but it 
looks like that's fixed it.

Further testing showed that I also had to disable rx checksumming, 
otherwise I was getting random kernel crashes. Presumably it was not 
only reading data from random memory locations, but also writing in the 
wrong place...

So, do I understand correctly that this is causing the CPU rather than 
the NIC to do the checksumming?

Is this a reasonable permanent solution?

Crashing aside, I'm a little nervous about putting into production a box 
that might for example randomly decide to serve up its SSL private keys 
halfway through an email message...

Cheers

/J


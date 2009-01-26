From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: IP address: property of host or interface?
Date: Mon, 26 Jan 2009 21:20:26 +0300
Message-ID: <497DFEEA.20700@msgid.tls.msk.ru>
References: <497B1E5E.9050309@msgid.tls.msk.ru> <497DF629.70602@hp.com> <497DFBC2.4030903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:47933 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613AbZAZSUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 13:20:30 -0500
In-Reply-To: <497DFBC2.4030903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Rick Jones wrote:
>>> So.. am I right that an IP address is a HOST property, not an INTERFACE
>>> property, and that the traditional way is just more convenient to set
>>> up? And
>>> that all the tools that complains that "there's no IP address
>>> assigned to this
>>> interface" (tcpdump) are wrong? :)
>>
>> There are two "schools" of thought - the Linux stack follows the "weak
>> end system" model in which IP addresses are treated as a host
>> property.  There is another school of thought called the "strong end
>> system" model where IP addresses are an interface property.  There are
>> some "other" stacks out there which can be configured to behave in a
>> "strong end system" way but they tend to default to more of something
>> in between the two.

As someone else pointed out, it's all described in RFC1122 (1989!).
It was quite.. interesting reading.

>> Tcpdump may simply be caught in the middle :)

heh.

> With a bit of configuring (away from system defaults), Linux can behave
> as a 'strong end system', and even

Well, that's quite "a bit". Involves iptable filters.

> in default behaviour, I don't believe it will process IP packets from an
> interface that has NO IP address assigned
> to it.

Just try it.  Trivial to do.  Assume you've a "simple-workstation"
config (no fancy stuff just lo and eth0 with single ip) with
192.168.1.5/24 on your eth0:

# ip addr add 192.168.1.5/32 dev lo  <== assigns that IP to lo interface
# ifconfig eth0 0.0.0.0  <= clears it (and routes) from eth0 but
                         <= keeps the interface up
# ip route add 192.168.1.0/24 dev eth0 <= restores the route

Now ping (or whatever) 192.168.1.5 from any host on eth0 segment.
All IP/TCP/UDP/etc stuff will work as usual.

/mjt

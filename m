From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: modifying tcp/ip stack
Date: Sat, 21 Aug 2004 12:22:47 +0200 (CEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.61.0408211213090.17163@filer.marasystems.com>
References: <20040821054621.95115.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: net dev <netdev@oss.sgi.com>, linux net <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20040821054621.95115.qmail@web41403.mail.yahoo.com>
List-Id: netdev.vger.kernel.org

On Fri, 20 Aug 2004, cranium2003 wrote:

>        What exactly i want to do is that i want to
> add a new protocol headerin between IP and ETHERNET
> header.

>From my understanding this is best done in two pieces:

a) A virtual network driver which adds your protocol header and then hands 
off the packet to the intended destination device.

b) A net net_protocol which parses your protocol header and then hands off 
the packets to the next layer (IP or whatever). Alternatively it can be a 
added as a packet_type to the device using dev_add_pack() which steals the 
packet from the original device and then reinjects them as coming from 
your device after processing your protocol header.

It may also be possible using the xfrm framework in 2.6 without using any 
of the above, but I am not familiar with how this works.

Regards
Henrik

From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: Thu, 6 Nov 2003 12:31:28 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311060931.MAA14771@yakov.inr.ac.ru>
References: <3FA7DBB5.1090500@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com (David S. Miller), jmorris@redhat.com, hadi@znyx.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com (Chris Friesen)
In-Reply-To: <3FA7DBB5.1090500@nortelnetworks.com> from "Chris Friesen" at Nov 04, 2003 12:02:45 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> If that were the case, I'd be happy.  However, when you set the TOS bits 
> (which really sets the whole 8-bit field, rather than just the 4 TOS 
> bits),

It was not our choice. :-)


> the kernel also sets the socket priority but only uses the TOS 
> bits to do so. 

Look at straces of your telnet, ftp and ssh. You will understand why
it is made and why it would be better not to change this. It affects
local queuing in right way in default situation.


>      If we're going to set the whole 8-bit field, wouldn't it 
> make sense to use the priority bits to set the priority?

There are no "priority" bits in this field. Priority is defined
by outgoing device.


> If root wants to send out a packet with particular DSCP settings, 
> doesn't it make sense to make that option available?  It's a field in 
> the IP packet header, we should be able to set it with an IP option.

IP_TOS. :-)

I feel there is some misunderstanding about sk->priority thing.
It is the lowest significance hint about priority, when no other
classification is supplied. Read: when the node is dumb and is not aware
about any such things.

I would agree with you if this field had opposite priority:
i.e. overrided all the system-wide settings. It does not.

What's about VLAN thing, this approach enforces you to use
DSCP directly and never use skb->priority (well, to be more exact,
to use it when you have no another hints available: in this case
our skb->priority is _right_ hint)

Alexey

From: David Brownell <david-b@pacbell.net>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 11:55:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAB1305.10805@pacbell.net>
References: <Pine.GSO.4.30.0210140918170.26803-100000@shell.cyberus.ca>
 <3DAB0982.C0C6E36F@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>- NOTPRESENT makes sense more from a NMS pov where a hotplug device has
>>been removed and SNMP finds that the device is no longer there. This
>>can be done without any state from the kernel being exposed.
> 
> 
> I want to forward this question mainly to the USB people. David, as you
> are familiar with this thread, how does an USB  driver react when an
> ethernet device is configured, running and then disconnected from the
> USB port? From RFC2863, I'd expect the devicename ethx not to be removed
> at least until it is ifconfigured down, but change from UP to NOTPRESENT
> until reconnection. So it would be useful to have this state inside the
> kernel.

Right now almost all USB networking drivers make the device disappear
immediately ... certainly the ones that have made sure they handle the
USB disconnect processing correctly (no more I/O to that device!) tend
to do that, by calling unregister_netdev().

And they don't try reconnection.  The goal of disconnect processing has
been to scrub out all the relevant device state; only the usb-storage
driver tries to keep a history of devices that have ever been attached,
so it can make "/dev/sdg" mean the same thing until reboot.

I wouldn't swear that unregistering is the perfect solution, but it's
clearly better than the oopses that tended to show up previously.
(And oddly enough, the drivers that _don't_ unregister seem to be the
ones that still have an EXPERIMENTAL label in the 2.5 kernels.)

- Dave

(Note that I'm just skimming this thread at the moment, limited time...
good that you cc'd me directly.)

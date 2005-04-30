From: jamal <hadi@cyberus.ca>
Subject: Re: Pktgen receive hook in dev.c?
Date: Fri, 29 Apr 2005 20:41:21 -0400
Message-ID: <1114821681.8929.32.camel@localhost.localdomain>
References: <4272C384.50901@candelatech.com>
	 <1114820059.8929.17.camel@localhost.localdomain>
	 <4272D133.4040201@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4272D133.4040201@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-29-04 at 17:28 -0700, Ben Greear wrote:
> jamal wrote:

> > Write an action. It should be trivial to consume pktgen. Infact if all
> > you wanted was to count, use the gact action.
> 
> I want a lot more than count, including timestamp, sequence number, etc.
> 

Sure you can do all that good stuff in your own action.

> In order to know it's a pktgen packet, I check for a magic value at the beginning
> of the UDP header.

Use the u32 classifier like so:

on dev eth0, if you see some magic signature on udp described as ...
then action my pktgen action.

>   Since this could potentially collide with some 'real' packet,

The classifier allows you to discriminate

> I also check a flag to see if the net_device has a particular flag set indicating
> it is actively accepting pktgen packets...
> 

Thats not needed. You should be able to attach a u32 classifier to any
device of your choice.

> I assume this means I'd need a custom match function in the kernel.

Refer to above - i dont think you do need to put any flag in a device.

>   Is there
> an example of how to do something like this using your framework?

I explained a few things to you last time you showed up and tried to put
hooks. Start there then ask questions. Its pretty simple.

cheers,
jamal

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Make ipconfig.c work as a loadable module.
Date: 07 Mar 2003 19:03:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m1fzpylimr.fsf@frodo.biederman.org>
References: <Pine.LNX.4.44.0303071223480.30312-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>, Chris Dukes <pakrat@www.uk.linux.org>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
   Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0303071223480.30312-100000@kenzo.iwr.uni-heidelberg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:

> On Fri, 7 Mar 2003, Russell King wrote:
> 
> > Which version is overly bloated?
> > Which version is huge?
> > Which version is compact?
> 
> ... and the size is not important only because we want to make everything 
> smaller, but because of how it's commonly used (at least in the clustering 
> world from which I come):
> 
> the mainboard BIOS or NIC PROC contains PXE/DHCP client; data is 
> transferred through UDP, with very poor (if any) congestion control. 

Only because the implementations suck.  See etherboot.

> Congestion control means here both extreme situations: if packets don't 
> arrive to the client, it might not ask again, ask only a limited number of 
> times or give up after some timeout; if the server has some faster NIC to 
> be able to handle more such requests, it might also send too fast for a 
> single client which might drop packets. In some cases, if such situation 
> occurs, the client just blocks there printing an error message on the 
> console, without trying to restart the whole process and the only way to 
> make it do something is to press the Reset button or plug in a keyboard... 
> When you have tens or hundreds of such nodes, it's not a pleasure !

But this is all before the kernel is loaded.  Having booted a 1000 node
cluster with TFTP and DHCP.  From a single host with even being in the same
town, I think I have some room to talk.
 
> Booting a bunch of such nodes would become problematic if they need 
> to transfer more data (=initrd) to start the kernel and so network booting 
> would become less reliable. Please note that I'm not saying "ipconfig has 
> to stay" - just that any solution should not dramatically increase the 
> size of data transferred before the jump to kernel code.

Right.  But I would suggest fixing your NBP (what PXE load) which must
be < 64K anyway if you have noticeable reliability problems.  Not that
I even suggest using PXE for production use anyway.  But sometimes
you are stuck with what you can do.

Eric

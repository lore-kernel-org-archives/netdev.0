From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Make ipconfig.c work as a loadable module.
Date: 08 Mar 2003 09:07:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m14r6dlu4w.fsf@frodo.biederman.org>
References: <Pine.LNX.4.44.0303081132030.12316-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>, Chris Dukes <pakrat@www.uk.linux.org>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
   Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0303081132030.12316-100000@kenzo.iwr.uni-heidelberg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:

> On 7 Mar 2003, Eric W. Biederman wrote:
> 
> > Only because the implementations suck.  See etherboot.
> 
> Agreed, but as you rightly say at the end of your message...
> 
> > But sometimes you are stuck with what you can do.
> 
> ... and you can't go use etherboot or whatever, you have to deal with it. 

At the very least I can use etherboot as a NBP in PXE terms.   So I have
a reasonable client after the first tftp transaction.

> You can deal with it today because ipconfig is small, you might not be 
> able to deal with it tomorrow if you'll have to transfer twice as much 
> because of a big initrd.

I routinely support an initrd with:
glibc.
/bin/bash
dhclient
mke2fs
mkreiserfs
parted
sfdisk
mount
pivot_root
etc.  (All binaries were striped though).
And I usually have to pass an ramdisk_size=XXX option to the kernel or
my decompressed initial ramdisk is to large.  I use it for setting up
a local filesystem on a cluster node.  And I was able to setup an
entire cluster 1000 node cluster in about 15-20 minutes.  (Multicast cuts
down on the bandwidth requirements which is very nice).

With a good bootloader it does not much how big your initrd is.  I
totally agree that small is good and important.  At the same time
ipconfig.c is wrong.  It is great during development and on systems
with a single NIC.  But the hard coded policies can be bad for
production systems.  Not that hard coded policies are bad in general
just the kernel is the wrong place to put them.

> > But this is all before the kernel is loaded. 
> 
> But that's exactly my point. The ipconfig functionality is needed and what 
> I ask for is that whatever means (if any) are chosen to replace it, they 
> should keep the low size.

Similar functionality is definitely needed.
> 
> > Having booted a 1000 node cluster with TFTP and DHCP.
> 
> I do not doubt this, but I'm afraid that you (or we) might not be able to 
> do it again tomorrow. And probably this is an ideal case where you have 
> used the better solution as client (etherboot)...

True.  But when things are important and the there is GPL'd firmware
available that actually works properly.  It is worth putting it on the
requirements list of things to do.

Eric

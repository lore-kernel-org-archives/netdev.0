From: Steven Whitehouse <steve@gw.chygwyn.com>
Subject: DECnet patch for 2.5
Date: Thu, 3 Oct 2002 11:31:01 +0100 (BST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210031031.LAA29397@gw.chygwyn.com>
Reply-To: Steve Whitehouse <Steve@ChyGwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davej@suse.de, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Here is the URL for my latest DECnet patch (for 2.5 kernels only):

http://www.chygwyn.com/~steve/kpatch/decnet/decnet-2.5.40-autoconfig.diff

It changes the way that DECnet gets autoconfigured in order to make the
simple case of setting up an endnode easier. It also fixes several bugs
which I found along the way and does a bit of C99 cleanup in the
sysctl code.

I'm not ready for this to go to Linus yet, but I'd like the maximum number of
people possible to try it and send me feedback on any problems that are
seen. I've updated the docs to explain the new configuration procedure.

Other features are:

 o Outgoing packets set with correct source address when device MAC address
   isn't the same as the DECnet address
 o Updated TODO list
 o Updated socket allocation in the light of the socket layer changes in 2.5
 o Fixed a race in bind() system call
 o Fixed a bug in autobind where we were not checking a return value
 o Fixed locking on the default_device
 o Routing changes for loopback routes in order to allow the new 
   autoconfiguration changes to work as intended.
 o "hello" messages now sent for each address on an interface
 o Using multicast address filters to listen to extra unicast MAC addresses
   when they are not equal to the MAC address of the device (allows DECnet
   without setting MAC address to a DECnet compatible address and multiple
   DECnet addresses per interface)
 o Unregisters the "all endnodes" or "all routers" multicast addresses when
   the device goes down (previously we forgot, causing an address leak).
 o Updated version string

I'll back port the bug fix parts to 2.4 in chunks once this has had a bit of
testing,

Steve.

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI Express adapters...
Date: Tue, 03 Jul 2007 09:19:26 -0400
Message-ID: <468A4CDE.5010808@garzik.org>
References: <4688F512.3030801@garzik.org> <46897934.5040101@garzik.org> <468990D8.6040604@intel.com> <200707021716.49637.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Michael Buesch <mb@bu3sch.de>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59891 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbXGCNTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 09:19:33 -0400
In-Reply-To: <200707021716.49637.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inaky Perez-Gonzalez wrote:
> I don't think bitfields are broken. Maybe it's the compiler what should be fixed (*)

Then you do not understand bitfields.  It is -axiomatic- that bitfields 
are more difficult for compilers to implement.

Access to bitfields are not atomic within the machine int in which they 
are stored... you need to "unpack" the values stored in bitfields, even 
if they are single-bit bitfields.

You cannot set multiple bitfields at one time, without even more complex 
data structures.  You cannot compare and test multiple bitfields at one 
  time.

Humans have proven in kernel-land to screw up bitfields repeatedly.

The evidence is plain to see:

> union {
>   struct {
>     u32 reserved1:15;
>     u32 val:2;
>    } __attribute__((packed))
>    u32 data;
> } value;

Using "u32 flags", and nothing else, is just so much more simple and 
obvious.

Finally, this is -nothing new-.  I've been telling other driver writers 
not to use bitfields in their drivers.  Google for 'garzik' and 'bitfield'.

	Jeff




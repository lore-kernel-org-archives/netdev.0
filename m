From: Steve Modica <modica@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 08 Oct 2003 13:21:50 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8455BE.8080300@sgi.com>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnip@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031008101046.376abc3b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Oh yeah?  What are your numbers like if you just disable the ia64
> kernel unaligned access printk()?

Hi David,

it's definitely not the printk.  They have that throttled so it only prints once 
for a large number of occurances.

The problem is that on the Altix platform they have to deal with unaligned 
accesses via an exception handler.  This causes them to run through hundreds of 
instructions.  There's evidntally another mechanism in the cpu that's more 
efficient in daling with unaligned accesses, but we can't use that for some 
reason (atomicity I think, but I don't recall).

This extra memcpy when the buffer is not unaligned currently only impacts 5701 
(since it's the only chip for which the 2 byte pad is omitted) although the 
alignment issue would bite us no matter what the chip if the 2 byte pad is omitted.

Steve


-- 
Steve Modica
work: 651-683-3224
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me

From: Andi Kleen <ak@suse.de>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Fri, 23 Jan 2004 23:22:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040123232209.2739e6aa.ak@suse.de>
References: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Leonid Grossman" <leonid.grossman@s2io.com>
In-Reply-To: <002201c3e1f6$f97896e0$5d50ff11@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jan 2004 13:22:11 -0800
"Leonid Grossman" <leonid.grossman@s2io.com> wrote:

> Hi all,
> Please fund attached a source code for S2io 10GbE adapter (with some
> disclaimers below).
> Send me your comments/suggestions on the source please,  and we will
> address the code changes (if any) in real time.

>From a quick look:

The debugging ioctls look quite dangerous. iirc they are not root projected
by higher level code. Either remove them or add a root check at least,
otherwise you'll have a potential root hole.

All the ARCH_PPC64 ifdefs shouldn't be needed. Can you remove that?
If there are problems in ppc64 code they should be fixed there, not worked
around. Same with the ifdefs for kernel 2.6 features. An driver integrated
into the kernel should not contain such ifdefs.

mdelay(100) is quite evil. Better make that a schedule_timeout() in 
process context.

ETH_GREGS/GEEPROM/SEEPROM/GSTRINGS ioctl handlers: seems to leak memory on error paths

ETH_SEEPROM: len should be limit checked

Running the driver through scripts/Lindent may not be a bad idea.

initNic: the jiffies check does not handle jiffies wrapping. 2.6 forces a jiffies wrap
5 minutes after boot, so this may be fatal. Use the right macros for this.

init_nic: x86-64 supports consistent dma masks too. in fact they should be just
used unconditionally.


-Andi

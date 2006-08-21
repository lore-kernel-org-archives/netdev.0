From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 doesn't receive any packages after I ssh in via ipv6 and
 edit a file in vim (reproducable)
Date: Mon, 21 Aug 2006 15:02:31 -0700
Message-ID: <20060821150231.31a947d4@localhost.localdomain>
References: <20060821212243.GA1558@cip.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37539 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751238AbWHUWGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 18:06:19 -0400
To: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
In-Reply-To: <20060821212243.GA1558@cip.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 23:22:43 +0200
Thomas Glanzmann <sithglan@stud.uni-erlangen.de> wrote:

> Hello,
> I have the newest sky2 driver (with the newest fix in version 1.5)
> running on my intel mac mini running under legacy bios modus. However if
> I ssh in via IPv6 and start vim in the shell to edit a file the sky2
> network adapter stops to work. This is reproducable. A friend of mine
> thought that maybe the IPv6 code doesn't request the right checksum. But
> I have no clue if it is related to this. I can give access to the
> machine via ssh (including root) if someone is willing to track this
> down. I have a userland programming running which reboots the machine if
> the network connectivity is lost. At least this one is reliable. If
> noone wants a shell account maybe someone can guide me through
> debugging and tracking this down.
> 
> (mini) [/var/log] grep sky2 kern.log
> Aug 20 20:52:10 mini kernel: sky2 v1.5 addr 0x90200000 irq 17 Yukon-EC (0xb6) rev 2
> Aug 20 20:52:10 mini kernel: sky2 eth0: addr 00:16:cb:a3:91:3c
> Aug 20 20:52:12 mini kernel: sky2 eth0: enabling interface
> Aug 20 20:52:12 mini kernel: sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
> Aug 20 21:01:34 mini kernel: sky2 eth0: hw error interrupt status 0x30
> Aug 20 21:01:34 mini kernel: sky2 eth0: ram data read parity error
> Aug 20 21:01:34 mini kernel: sky2 eth0: ram data write parity error
> Aug 20 21:01:34 mini kernel: sky2 eth0: hw error interrupt status 0x8
> Aug 20 21:01:34 mini kernel: sky2 eth0: MAC parity error

Something is happening long before you start doing ipv6.
The parity error's mean that the PCI transfers are going south.
The driver might be better to just shut it self off after that.

Perhaps the PCI access isn't working properly. What is the config?
Also are you running i386 or x86_64 on this.

Is this fix in your version?
	http://www.mail-archive.com/netdev@vger.kernel.org/msg18603.html


-- 
Stephen Hemminger <shemminger@osdl.org>

All non-trivial abstractions, to some degree, are leaky.

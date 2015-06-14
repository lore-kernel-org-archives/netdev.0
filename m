From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Sun, 14 Jun 2015 20:50:50 +0200
Message-ID: <557DCD0A.5040500@hartkopp.net>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:60245 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbbFNS5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 14:57:11 -0400
In-Reply-To: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.06.2015 12:00, Ulrich Gemkow wrote:

> between Linux 4.0.5 and 4.1-rc7 the name as shown by "ip link show"
> of bridge interfaces (and at least the dummy interface) changed from
> (i.e.) br1 to br1@NONE.
>
> This breaks (at least for me :-) userspace (ip link show parsing
> scripts). It is easy to solve, so not a big problem. I am using
> Ubuntu 14.04.
>
> Is this user visible change intended?
>

Hi Ulrich,

looking at iproute2 I found this patch:

http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/ip/ipaddress.c?id=ccdcbf35f120c754660b3b3f48fa67cc950a6407

 > iplink: add support of IFLA_LINK_NETNSID attribute
 > This new attribute is now advertised by the kernel for x-netns interfaces. 
 > It's also possible to set it when an interface is created (and thus
 > creating a x-netns interface with one single message).

Due to the fact that the kernel now provides the new attribute we get this 
@NONE stuff for interfaces that have no iflink value.

This definitely is @UGLY !

@Nicloas: Why don't you just omit the @NONE when iflink is zero in the new 
attribute?

Regards,
Oliver

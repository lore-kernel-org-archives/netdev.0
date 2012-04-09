From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC] API to modify /proc/sys/net/ipv4/ip_local_reserved_ports
Date: Mon, 09 Apr 2012 16:43:01 +0800
Message-ID: <1333960981.414.24.camel@cr0>
References: <4F5BE563.9050506@gmx.de> <4F5FAF28.5030205@gmx.de>
	 <4F611835.4080904@gmx.de> <4F7CADE8.3060205@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>, shemminger@vyatta.com
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916Ab2DIInO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 04:43:14 -0400
In-Reply-To: <4F7CADE8.3060205@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-04 at 22:24 +0200, Helge Deller wrote:
> I would like to follow up on my last patch series to be able to modify
> the contents of the /proc/sys/net/ipv4/ip_local_reserved_ports port list
> from userspace.
> 
> My last patch (https://lkml.org/lkml/2012/3/10/187) was based on
> modifications to the proc interface, which - based on the feedback here
> on the list - seemed to not be the right way to go (although I personally
> still like the idea very much :-)).
> 
> Anyway, with this RFC I would like to get feedback about a new proposed
> API and attached kernel patch.
> 
> The idea is to introduce a new <optname> value for get/setsockopt()
> named SO_RESERVED_PORTS to get/set the ip_local_reserved_ports
> bitmap via standard get/setsockopt() syscalls.
> As far as I understand this seems to be similiar to how iptables works.
> 
> An untested kernel patch for review and feedback is attached below.
> 
> In userspace it then would be possible to write a new tool or to extend
> for example the "ip" tool to accept commands like:
> $> ip reserved_ports add 100-2000
> $> ip reserved_ports remove 50-60
> $> ip reserved_ports list     (to show current reserved port list)
> 
> This userspace tool could then read the port bitmap from kernel via
> a) socket(PF_INET, SOCK_RAW, IPPROTO_RAW)
> b) getsockopt(3, SOL_SOCKET, SO_RESERVED_PORTS, <bitmaplist>)
> and write back the results after modification via
> c) setsockopt(3, SOL_SOCKET, SO_RESERVED_PORTS, <bitmaplist>)
> 
> Would that be an acceptable solution?

Hmm, it is indeed that bitmap fits for syscall rather than /proc file.

But it seems that using getsockopt()/setsockopt() makes it like it is a
per-socket setting, actually it is a system-wide setting. So I am
wondering if exporting a binary /proc file for this is a better
solution.

Thanks.

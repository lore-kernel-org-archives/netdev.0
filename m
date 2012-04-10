From: Helge Deller <deller@gmx.de>
Subject: Re: [RFC] API to modify /proc/sys/net/ipv4/ip_local_reserved_ports
Date: Tue, 10 Apr 2012 23:04:47 +0200
Message-ID: <4F84A06F.3090808@gmx.de>
References: <4F5BE563.9050506@gmx.de> <4F5FAF28.5030205@gmx.de>	 <4F611835.4080904@gmx.de> <4F7CADE8.3060205@gmx.de> <1333960981.414.24.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>, shemminger@vyatta.com
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:45179 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759354Ab2DJVEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 17:04:54 -0400
In-Reply-To: <1333960981.414.24.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2012 10:43 AM, Cong Wang wrote:
> On Wed, 2012-04-04 at 22:24 +0200, Helge Deller wrote:
>> I would like to follow up on my last patch series to be able to modify
>> the contents of the /proc/sys/net/ipv4/ip_local_reserved_ports port list
>> from userspace.
>>
>> My last patch (https://lkml.org/lkml/2012/3/10/187) was based on
>> modifications to the proc interface, which - based on the feedback here
>> on the list - seemed to not be the right way to go (although I personally
>> still like the idea very much :-)).
>>
>> Anyway, with this RFC I would like to get feedback about a new proposed
>> API and attached kernel patch.
>>
>> The idea is to introduce a new<optname>  value for get/setsockopt()
>> named SO_RESERVED_PORTS to get/set the ip_local_reserved_ports
>> bitmap via standard get/setsockopt() syscalls.
>> As far as I understand this seems to be similiar to how iptables works.
>>
>> An untested kernel patch for review and feedback is attached below.
>>
>> In userspace it then would be possible to write a new tool or to extend
>> for example the "ip" tool to accept commands like:
>> $>  ip reserved_ports add 100-2000
>> $>  ip reserved_ports remove 50-60
>> $>  ip reserved_ports list     (to show current reserved port list)
>>
>> This userspace tool could then read the port bitmap from kernel via
>> a) socket(PF_INET, SOCK_RAW, IPPROTO_RAW)
>> b) getsockopt(3, SOL_SOCKET, SO_RESERVED_PORTS,<bitmaplist>)
>> and write back the results after modification via
>> c) setsockopt(3, SOL_SOCKET, SO_RESERVED_PORTS,<bitmaplist>)
>>
>> Would that be an acceptable solution?
> Hmm, it is indeed that bitmap fits for syscall rather than /proc file.
>
> But it seems that using getsockopt()/setsockopt() makes it like it is a
> per-socket setting, actually it is a system-wide setting.
Yes, that's the reason why I used SOL_SOCKET which configures at least
a few system-wide settings too.

> So I am
> wondering if exporting a binary /proc file for this is a better
> solution.
Yeah - that's another solution, but (65536 ports)/(8 bits per byte) = 8 
KByte, so we
may again hit the 4k limit of /proc (unless you do binary reads which should
be done with a binary /proc-entry anyway).

Again, I'm open to develop any kind of solution which would get an OK here.

Helge

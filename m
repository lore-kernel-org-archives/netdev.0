From: Jiri Slaby <jslaby@suse.cz>
Subject: tun routing is broken [was: tun: Failed to create tun sysfs files]
Date: Sat, 05 Mar 2011 09:04:22 +0100
Message-ID: <4D71EE86.6030309@suse.cz>
References: <201103030127.p231ReNl012841@imap1.linux-foundation.org>	<4D70A929.4010900@suse.cz> <20110304.010603.104076956.davem@davemloft.net> <4D70B2DC.2000005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	netdev@vger.kernel.org, maxk@qualcomm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D70B2DC.2000005@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2011 10:37 AM, Jiri Slaby wrote:
> On 03/04/2011 10:06 AM, David Miller wrote:
>> From: Jiri Slaby <jslaby@suse.cz>
>> Date: Fri, 04 Mar 2011 09:56:09 +0100
>>
>>> On 03/03/2011 01:52 AM, akpm@linux-foundation.org wrote:
>>>> The mm-of-the-moment snapshot 2011-03-02-16-52 has been uploaded to
>>>
>>> Hi, I'm seeing this with tun (also with earlier versions):
>>
>> The name of the attribute was changed to netdev_group in order to
>> fix this problem, in fact quite some time ago.
>>
>> See the last entry of the net_class_attributes array in
>> net/core/net-sysfs.c, if it isn't called "netdev_group"
>> something is awry.
> 
> <idiocy>
> Aha, sorry for the noise, I booted the old kernel.
> </idiocy>

Ok, so I booted the new kernel, and tun is broken there completely. If I
try to ping a vpn peer:
...
capget(0x20080522, 0, NULL)             = 0
capset(0x20080522, 0, {0, 0, 0})        = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(1025),
sin_addr=inet_addr("10.20.11.1")}, 16) = -1 EINVAL (Invalid argument)

the route is:
10.20.11.1 dev tun0  proto kernel  scope link  src 10.20.11.33

When I try to ping a router on eth0 10.0.28.10, it works as expected.

Maybe the changes in ipv4 routing cause this? But my amateur eyes can't
see any breakage there...

Now I'm back in mmotm 2011-02-10-16-26 and it works, indeed.

regards,
-- 
js
suse labs

From: Ben Greear <greearb@candelatech.com>
Subject: Re: Bug in 2.6.10
Date: Fri, 28 Jan 2005 12:04:23 -0800
Message-ID: <41FA9AC7.5080007@candelatech.com>
References: <41FA9239.4010401@rapidforum.com>	<20050128114251.64e0fff4@dxpl.pdx.osdl.net> <20050128114600.46f3a70a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, webmaster@rapidforum.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050128114600.46f3a70a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 28 Jan 2005 11:42:51 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> 
>>On Fri, 28 Jan 2005 20:27:53 +0100
>>Christian Schmid <webmaster@rapidforum.com> wrote:
>>
>>
>>>Hello.
>>>
>>>In 2.6.10 there has been a "bug" introduced. You may also call it a feature, but its a crappy 
>>>feature for big servers. It seems the kernel is dynamically adjusting the buffer-space available for 
>>>sockets. Even if send-buffer has been set to 1024 KB, the kernel blocks at less if there are enough 
>>>sockets in use. If you have 10 sockets with 1024 KB each, they do not block at all, using full 1024 
>>>KB. If you have 4000 sockets, they only use 200 KB. So it seems its blocking at 800 MB. This is 
>>>good, if you have a 1/3 system, because else the kernel would run out of low mem. But I have a 2/2 
>>>system and I need them for buffers. So what can I do? Where can I adjust the "pool"?
>>
>>You can set the upper bound by setting tcp_wmem. There are three values
>>all documented in Documentation/networking/ip-sysctl.txt
> 
> 
> This feature is meant also to prevent remote denial of service
> attacks.  It limits the amount of system memory TCP can
> consume on your system.
> 
> Before this feature went in, it's really easy to remotely make a system
> consume %90 of system memory just with socket buffers.

Could you cause this attack without having the local machine explicitly
set it's local wmem buffers higher?

With the latest code, if you set the tcp_[rw]mem MAX to some really large thing,
as it appears Mr Schmid was doing, does the kernel just ignore the larger value
after 800MB?  I agree that by default the system should protect itself from OOM
attacks, but at the same time, if a user really wants to use up to 2GB of RAM for
buffers, I don't think we should stop them.

In addition to Mr Hemminger's suggestion, I think the more important knob
would be the /proc/sys/net/core/netdev_max_backlog which bounds the total
number of receive packets in the system, correct?  Is there a similar knob
for the total maximum number of buffers waiting in tx queues?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Tue, 13 Jan 2004 17:55:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4004A194.3030602@candelatech.com>
References: <20040113154610.38f5934c.shemminger@osdl.org>	<40048BFD.4010303@candelatech.com> <20040113163828.64ec4743.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <20040113163828.64ec4743.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 13 Jan 2004 16:23:25 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Stephen Hemminger wrote:
>>
>>>When using pseudo network devices, and really big machines; there is
>>>sometimes a need to have a lot of network devices.  This replaces the
>>>existing 2.6.1 limit of 100 entries an was O(n^2)
>>>with a algorithm that will handle up to 32768 entries with O(n) behaviour.
>>
>>Might be a good time to put in hash tables to find network devices by
>>name and by device-id.  There are a few parts of the networking stack
>>that do lookups, and walking the device list when it's 4k entries
>>long takes a while...
> 
> 
> I have a patch for name hashing, but don't know if it's needed.
> Even without it I can add 9 thousand bridge entries,
> and each one takes longer to start the command than add the entry now. 

Check out the af_packet code.  At least some branches do a
device lookup by name for each transmitted packet.  One
method is:  packet_sendmsg_spkt

packet_sendmsg gets by index, which could also be hashed...

At one time ifconfig -a was almost un-usable with large numbers
of devices, but I think it has been improved.  I haven't tried on
large numbers of devices lately...

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

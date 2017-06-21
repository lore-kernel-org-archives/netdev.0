From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: implement basic ethtool
 get_settings
Date: Wed, 21 Jun 2017 13:59:45 -0700
Message-ID: <24dd8cf5-9fba-abb6-031f-b46b017e5e9f@oracle.com>
References: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
 <1498061394-233018-3-git-send-email-shannon.nelson@oracle.com>
 <20170621.150634.1121246733116528491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170621.150634.1121246733116528491.davem@davemloft.net>
Content-Language: en-US
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/2017 12:06 PM, David Miller wrote:
> From: Shannon Nelson <shannon.nelson@oracle.com>
> Date: Wed, 21 Jun 2017 09:09:54 -0700
> 
>> Add the get_settings callback so that both the ldmvsw and sunvnet
>> drivers will give a little more information when asked for its
>> basic settings.  These aren't necessarily very useful, but they
>> make some users happier.  Also, a side effect is that the speed
>> attribute in /sys/class/net/<dev> is now readable, which makes
>> a couple of the ldom management tools happier.
>>
>> Orabug: 26175474
>>
>> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> 
> I would set the speed to something other than zero, and also

I kept looking at that and wasn't sure which value to pretend with.  I 
looked at what was reported in the Solaris world and saw '0' so went 
with that.  I suppose using SPEED_10000 shouldn't hurt anything, and is 
close enough to observed client-to-client speeds.

> consider the ramifications of this change upon things like
> 'bonding' and 'team'.

The request I was responding to with this was really more targeted at 
the ldmvsw (host) side of the connection, the vif device, which I 
believe only ever gets connected to the vsw bridge.  You're right, tho', 
because the eth0 in the ldom client *does* get sucked into teams.  I may 
drop the sunvnet/client side of this patch and stick with just the 
host/ldmvsw side.

Thanks,
sln

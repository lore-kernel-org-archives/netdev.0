From: Jet Chen <jet.chen@intel.com>
Subject: Re: [net] WARNING: CPU: 1 PID: 1 at net/batman-adv/hard-interface.c:92
 batadv_is_on_batman_iface()
Date: Thu, 22 May 2014 15:34:01 +0800
Message-ID: <537DA869.9070108@intel.com>
References: <537D8030.8010403@intel.com> <CAHA+R7Mhd2KYaU8THAd+O4HzQNRLxhpGccvEPOqWJRKAwZbpgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7Mhd2KYaU8THAd+O4HzQNRLxhpGccvEPOqWJRKAwZbpgQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2014 02:12 PM, Cong Wang wrote:
> On Wed, May 21, 2014 at 9:42 PM, Jet Chen <jet.chen@intel.com> wrote:
>> Hi Steffen,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
>> commit 78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb
>> Author:     Steffen Klassert <steffen.klassert@secunet.com>
>> AuthorDate: Mon May 19 11:36:56 2014 +0200
>> Commit:     David S. Miller <davem@davemloft.net>
>> CommitDate: Wed May 21 02:08:32 2014 -0400
>>
>>      ip_tunnel: Initialize the fallback device properly
>>          We need to initialize the fallback device to have a correct mtu
>>      set on this device. Otherwise the mtu is set to null and the device
>>      is unusable.
>>          Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
>>      Cc: Pravin B Shelar <pshelar@nicira.com>
>>      Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>>      Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> +--------------------------------------------------------------------------------+------------+------------+
>> |
>> | d8d33c3b8a | 78ff4be45a |
>> +--------------------------------------------------------------------------------+------------+------------+
>> | boot_successes
>> | 60         | 0          |
>> | boot_failures
>> | 0          | 20         |
>> |
>> WARNING:CPU:PID:at_net/batman-adv/hard-interface.c:batadv_is_on_batman_iface()
>> | 0          | 20         |
>> | backtrace:register_netdevice_notifier
>> | 0          | 20         |
>> | backtrace:batadv_init
>> | 0          | 20         |
>> | backtrace:kernel_init_freeable
>> | 0          | 20         |
>> +--------------------------------------------------------------------------------+------------+------------+
>>
>
> batman needs to fix:
>
> diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
> index b851cc5..fbda6b5 100644
> --- a/net/batman-adv/hard-interface.c
> +++ b/net/batman-adv/hard-interface.c
> @@ -83,7 +83,7 @@ static bool batadv_is_on_batman_iface(const struct
> net_device *net_dev)
>                  return true;
>
>          /* no more parents..stop recursion */
> -       if (net_dev->iflink == net_dev->ifindex)
> +       if (net_dev->iflink == 0 || net_dev->iflink == net_dev->ifindex)
>                  return false;
>
>          /* recurse over the parent device */
>
Your patch fixes that issue.

Tested-by: Jet Chen <jet.chen@intel.com>

Thanks,
Jet

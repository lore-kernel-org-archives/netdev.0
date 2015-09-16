From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 16 Sep 2015 12:45:45 +0200
Message-ID: <CAFnufp0eb5B-j7MOzyLMMjvcD2gupYP4pNH-GUuoGy7zKzewdg@mail.gmail.com>
References: <20150915.120057.1457031142615117336.davem@davemloft.net>
 <1442397259-28894-1-git-send-email-matteo@openwrt.org> <55F943F1.4030903@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55F943F1.4030903@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-09-16 12:26 GMT+02:00 Daniel Borkmann <daniel@iogearbox.net>:
> On 09/16/2015 11:54 AM, Matteo Croce wrote:
>>
>> Add option to disable any reply not related to a listening socket,
>> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
>> Also disables ICMP replies to echo request and timestamp.
>> The stealth mode can be enabled selectively for a single interface.
>>
>> Signed-off-by: Matteo Croce <matteo@openwrt.org>
>> ---
>> rebased on 4.3-rc1
>>
>>   Documentation/networking/ip-sysctl.txt | 14 ++++++++++++++
>>   include/linux/inetdevice.h             |  1 +
>>   include/linux/ipv6.h                   |  1 +
>>   include/uapi/linux/ip.h                |  1 +
>>   net/ipv4/devinet.c                     |  1 +
>>   net/ipv4/icmp.c                        |  6 ++++++
>>   net/ipv4/ip_input.c                    |  5 +++--
>>   net/ipv4/tcp_ipv4.c                    |  3 ++-
>>   net/ipv4/udp.c                         |  4 +++-
>>   net/ipv6/addrconf.c                    |  7 +++++++
>>   net/ipv6/icmp.c                        |  3 ++-
>>   net/ipv6/ip6_input.c                   |  5 +++--
>>   net/ipv6/tcp_ipv6.c                    |  2 +-
>>   net/ipv6/udp.c                         |  3 ++-
>>   14 files changed, 47 insertions(+), 9 deletions(-)
>>
>> diff --git a/Documentation/networking/ip-sysctl.txt
>> b/Documentation/networking/ip-sysctl.txt
>> index ebe94f2..1d46adc 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -1206,6 +1206,13 @@ igmp_link_local_mcast_reports - BOOLEAN
>>         224.0.0.X range.
>>         Default TRUE
>>
>> +stealth - BOOLEAN
>> +       Disable any reply not related to a listening socket,
>> +       like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
>> +       Also disables ICMP replies to echo requests and timestamp
>> +       and ICMP errors for unknown protocols.
>> +       Default value is 0.
>> +
>
>
> Hmm, what about all other protocols besides TCP/UDP such as SCTP, DCCP,
> etc? It seems it gives false expectations in such cases when the user
> enables being "stealth", but finds out it has no effect at all there ...
> nmap f.e. has a couple of scanning options for SCTP, and at least SCTP
> is still relevant in telco space.
>
> I know this question has been asked before, but the only answer on this
> was so far: "well, I've never played with SCTP before" ... :/

Right, I was thinking to add them in a later version

-- 
Matteo Croce
OpenWrt Developer
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 CHAOS CALMER
 -----------------------------------------------------
  * 1 1/2 oz Gin            Shake with a glassful
  * 1/4 oz Triple Sec       of broken ice and pour
  * 3/4 oz Lime Juice       unstrained into a goblet.
  * 1 1/2 oz Orange Juice
  * 1 tsp. Grenadine Syrup
 -----------------------------------------------------

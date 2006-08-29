From: Peter Bieringer <pb@bieringer.de>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 13:13:58 +0200
Message-ID: <44F42176.1000701@bieringer.de>
References: <20060829082435.GA2676@suse.de> <20060829.183426.52410264.yoshfuji@linux-ipv6.org> <20060829.025400.37356422.davem@davemloft.net> <Pine.LNX.4.64.0608291348520.25442@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	okir@suse.de, netdev@vger.kernel.org, jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.aerasec.de ([212.18.21.179]:6858 "EHLO smtp4.aerasec.de")
	by vger.kernel.org with ESMTP id S932306AbWH2LOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 07:14:10 -0400
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.64.0608291348520.25442@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Savola schrieb:
> On Tue, 29 Aug 2006, David Miller wrote:
>> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date: Tue, 29 Aug 2006 18:34:26 +0900 (JST)
>>
>>> Further analysis is needed, but one idea is to skip
>>> addrconf_dev_config() if !(dev->flags & IFF_MULTICAST).
>>
>> Yes, it is logical because without multicast IPV6 cannot
>> work correctly.
>>
>> But from another perspective (I assume these bridged Xen devices use
>> ARPHRD_ETHER, do they?) a device with ARPHRD_ETHER and cleared
>> IFF_MULTICAST flag seems potentially problematic.  How many other
>> things break over such a device?
> 
> It's not obvious that IFF_MULTICAST is good enough.  IMHO, you should be
> able to run addrconf on non-multicast interfaces as well (e.g.,
> point-to-point interfaces, tunnels in particular).

Hmm, at least on RHEL4 (2.6.9):

1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
3: eth1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
4: sit0: <NOARP> mtu 1480 qdisc noop
5: sit1@NONE: <POINTOPOINT,NOARP,UP> mtu 1480 qdisc noqueue
6: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP> mtu 1492 qdisc pfifo_fast qlen 3
8: tun6to4@NONE: <NOARP,UP> mtu 1480 qdisc noqueue


And contributed from FC5:

5: vmnet8: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
1000
7: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,10000> mtu 1500 qdisc
pfifo_fast qlen 100


ppp0, tun0 has IFF_MULTICAST set, so not an issue.

> It seems that current code already excludes IFF_NOARP interfaces though.

So 6-in-4 tunnels are already except.


Don't wonder about Flag "10000", missing support in "ip", already
reported https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=202199 and
fixed in rawhide.


Just my 2 cents,

	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889

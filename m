From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: "martian source" mixes up source and destination
Date: Sun, 29 Apr 2012 08:52:56 +0400
Message-ID: <4F9CC928.5040909@msgid.tls.msk.ru>
References: <jnh9tl$rth$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Mantas M." <grawity@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <jnh9tl$rth$1@dough.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28.04.2012 21:37, Mantas M. wrote:
> After enabling the /proc/sys/net/ipv4/conf/all/log_martians sysctl, I've
> been receiving the following messages on dmesg:

Cc'ing netdev@vger for network-related question.

>> martian source 255.255.255.255 from 192.168.1.115, on dev wlan0
>> ll header: ff:ff:ff:ff:ff:ff:f4:6d:04:85:fc:d7:08:00
>> martian source 192.168.1.255 from 192.168.1.115, on dev wlan0
>> ll header: ff:ff:ff:ff:ff:ff:f4:6d:04:85:fc:d7:08:00
>> martian source 192.168.1.255 from 192.168.1.115, on dev wlan0
>> ll header: ff:ff:ff:ff:ff:ff:f4:6d:04:85:fc:d7:08:00
>> <later>
>> martian source 255.255.255.255 from 192.168.1.183, on dev eth0
>> ll header: ff:ff:ff:ff:ff:ff:48:5d:60:e8:65:8f:08:00

It has been this way since very long time.  The meaning of this
message is:

  there is a martian source sending packets to 255.255.255.255
  from 192.168.1.183 on dev eth0

> However, the packets are *not* martians, but legitimate broadcast
> UDP/IPv4 packets: they have the *destination* as 255.255.255.255 or
> 192.168.1.255, with the source being 192.168.1.115 (wlan0 on this
> device) for the first three packets, and 192.168.1.183 (eth0) on the
> fourth.

log_martians does not check destination address, it checks _source_
address.  At least it did so in the past.  Please show output of
`ip route' from your machine.

> Linux 3.3.4-1-ARCH on Arch Linux

Thanks,

/mjt

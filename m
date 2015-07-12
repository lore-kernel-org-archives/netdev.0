From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH v2] add stealth mode
Date: Mon, 13 Jul 2015 01:13:44 +0200
Message-ID: <CAFnufp1_JAutAm7LZsQXXPspipUy4n2C9K3Li+jsWzNpgqYBJw@mail.gmail.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
 <21611.1436179798@turing-police.cc.vt.edu> <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
 <559D2688.5020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <559D2688.5020302@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-07-08 15:32 GMT+02:00 Austin S Hemmelgarn <ahferroin7@gmail.com>:
> On 2015-07-06 15:44, Matteo Croce wrote:
> Just to name a few that I know of off the top of my head:
> 1. IP packets with any protocol number not supported by your current kernel
> (these return a special ICMP message).

Right, I'll handle them

> 2. SCTP INIT and COOKIE_ECHO chunks when you have SCTP enabled in the
> kernel.

Well, I've never played with SCTP before

> 3. Theoretically, some IGMP messages.
> 4. NDP messages.
> 5. ARP queries looking for the machine's IP addresses.

Yes I know, but it's unlikely to receive this packets from WAN, right?
My flag is intended to be used mostly on WAN interfaces,
machines in LAN should be easily discoverable IMHO

> 6. Certain odd flag combinations on single TCP packets (check the
> documentation for Nmap for more info regarding these), which I believe
> (although I may be reading the code wrong) you aren't accounting for.

I've tried many TCP flags combination with hping3, NUL, SYN/ACK, ACK,
SYN/FIN, etc.
They doesn't get any response when the flag is set

> 7. DAD queries.

Never looked at this packets, are a subset of NDP?

> 8. ICMP address mask queries (which you also don't appear to account for).

It's deprecated and actually it doesn't get any response already

> This is by no means an exhaustive list, but all of them really should be
> addressed if you want to do this properly.
>
>

Thank you,
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

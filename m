From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 17:40:21 -0800
Message-ID: <420C0D05.6020408@hp.com>
References: <20050210002356.500401f7.akpm@osdl.org>	<20050210.182225.07335127.yoshfuji@linux-ipv6.org>	<20050210122523.41276d5a.davem@davemloft.net> <20050211.092916.50162307.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ikebe.takashi@lab.ntt.co.jp, akpm@osdl.org,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050211.092916.50162307.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>I guess this causes problems for ipv6 local addresses, it
>>will need to catch some callback to handle these events and
>>thus adjust the local address properly.
> 
> 
> Okay, I'll try to solve it:
> 1) catch NETDEV_CHANGEADDR
> 2) (try to) add new link-local address and deprecate old one.
> 3) (when DAD finishes) RS will be sent.

At present, for IPv4 if someone changes the MAC address of an interface, 
existing TCP connections don't really care right?  The ARP caches will be 
updated with a new IPv4 to MAC translation and happiness and joy ensues.

So, what would happen to TCP connections over IPv6 using link-local addresses? 
If the old address is taken away (deprecated), and a new address generated, 
doesn't that mean that TCP connections (using link-local addresses anyway) will 
fail on a MAC change?

rick jones

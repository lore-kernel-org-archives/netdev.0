From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 18:22:25 +0900 (JST)
Message-ID: <20050210.182225.07335127.yoshfuji@linux-ipv6.org>
References: <20050210002356.500401f7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ikebe.takashi@lab.ntt.co.jp, yoshfuji@linux-ipv6.org, davem@davemloft.net,
        akpm@osdl.org, ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
To: netdev@oss.sgi.com
In-Reply-To: <20050210002356.500401f7.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050210002356.500401f7.akpm@osdl.org> (at Thu, 10 Feb 2005 00:23:56 -0800), Andrew Morton <akpm@osdl.org> says:

> http://bugme.osdl.org/show_bug.cgi?id=4189
> 
>            Summary: IPv6 link local addresses are not assigned correctly on
>                     multiple-bonding enviromrnts
>     Kernel Version: 2.6.10
>             Status: NEW
>           Severity: normal
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: ikebe.takashi@lab.ntt.co.jp
:
> It create ipv6 address from MAC address, however it seems dev->dev_addr is "0"
> in the case of bonding.

I don't think it is the case.

> Steps to reproduce:
> 1.set the multiple bonding to the machine.
> (In my case, set 4 nics to use the bonding, and set the double bond as following
> modprobe.conf.

This is the key. That we do is:

# ifconfig bond0 up <= here fe80::200:ff:fe00:0/64 is assigned
# ifenslave bond0 eth0 ...

IPv6 Link-local address is configured just after the
corresponding device is enabled. MAC should be configured
before you bring up the interface.

So, currently, you need to do this:

# ip link set bond0 address 00:01:02:03:04:05
# ifconfig bond0 up <= here fe80::200:ff:fe00:0/64 is assigned
# ifenslave bond0 eth0 ...

BTW, why is it required to bring up bonding device before its configuratoin?
Ethernet devices is not allowed to change its MAC during it is up.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

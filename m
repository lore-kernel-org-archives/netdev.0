From: Takashi Ikebe <ikebe.takashi@lab.ntt.co.jp>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 20:59:18 +0900
Message-ID: <420B4C96.9010808@lab.ntt.co.jp>
References: <20050210002356.500401f7.akpm@osdl.org>	<20050210.182225.07335127.yoshfuji@linux-ipv6.org> <20050210.182517.55994883.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, akpm@osdl.org,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050210.182517.55994883.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think this cause by network init script.
network init script always bring up ifcfg-[A-Za-z0-9\._-],
so ifcfg-bond* always bring up before ifcfg-eth*! ("b" is before "e" in
alphabet order!)
I see, this is not a kernel issue, and this is initscript issue.


YOSHIFUJI Hideaki / 吉藤英明 wrote:
> Sorry for typo...
> 
> In article <20050210.182225.07335127.yoshfuji@linux-ipv6.org> (at Thu, 10 Feb 2005 18:22:25 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> 
>>So, currently, you need to do this:
>>
>># ip link set bond0 address 00:01:02:03:04:05
>># ifconfig bond0 up <= here fe80::200:ff:fe00:0/64 is assigned
> 
>                               fe80::201:02ff:fe03:0405 is assigned
> 
>># ifenslave bond0 eth0 ...
> 
> 


-- 
Takashi Ikebe
NTT Network Service Systems Laboratories
9-11, Midori-Cho 3-Chome Musashino-Shi,
Tokyo 180-8585 Japan
Tel : +81 422 59 4246, Fax : +81 422 60 4012
e-mail : ikebe.takashi@lab.ntt.co.jp

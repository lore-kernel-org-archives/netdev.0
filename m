From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: REDIRECT in nat OUTPUT
Date: Sun, 13 Jul 2008 16:59:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807131656500.4816@bizon.gios.gov.pl>
References: <200807120424.56462.denys@visp.net.lb> <200807121740.25789.denys@visp.net.lb>
 <20080713140930.GA23238@2ka.mipt.ru> <200807131719.50777.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-900395503-1215961167=:4816"
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807131719.50777.denys@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-900395503-1215961167=:4816
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sun, 13 Jul 2008, Denys Fedoryshchenko wrote:

> On Sunday 13 July 2008, Evgeniy Polyakov wrote:
>> On Sat, Jul 12, 2008 at 05:40:25PM +0300, Denys Fedoryshchenko (denys@vi=
sp.net.lb) wrote:
>>> Seems i found something. After issuing ethtool -K lo tso on i got signi=
ficant performance improvement.
>>> Why it is not on by default?
>>> Without it performance is VERY poor.
>>
>> TSO over loopback turns to be GSO, which allows to aggregate multiple
>> packets into single frame. If system is not CPU bound, then it is likely
>> REDIRECT problem. If I understood you corerctly, loopback performance is
>> always good without REDIRECT, but fails to miserable level when
>> apprpriate rule is used?
>>
> No, seems it has performance issues without redirect(and conntrack unload=
ed too) even, iperf results on loopback is very unstable.
>
> Actually i dont understand, how on idle machine with Xeon processor iperf=
 over loopback (tcp) can be ~100Mbps?
> I think it is a bug.

Something is wrong here as:

root@fw2-t:~# iperf -c 127.1
------------------------------------------------------------
Client connecting to 127.1, TCP port 5001
TCP window size: 49.2 KByte (default)
------------------------------------------------------------
[  3] local 127.0.0.1 port 36419 connected with 127.0.0.1 port 5001
[  3]  0.0-10.0 sec  7.10 GBytes  6.10 Gbits/sec

# uname -r
2.6.24.7-o4

# grep "model name" /proc/cpuinfo|uniq
model name      : Intel(R) Xeon(R) CPU           X5460  @ 3.16GHz

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-900395503-1215961167=:4816--

From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 17:48:36 +0100
Message-ID: <47879DE4.8080603@cosmosbay.com>
References: <1199981839.8931.35.camel@cafe>	 <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com> <1200068444.9349.20.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.100]:43932 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759302AbYAKQso convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 11:48:44 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2807.orange.fr (SMTP Server) with ESMTP id 6EC598000043
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:48:42 +0100 (CET)
In-Reply-To: <1200068444.9349.20.camel@cafe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao a =E9crit :
> On Thu, 2008-01-10 at 12:52 -0800, Brandeburg, Jesse wrote:
>  =20
>> Breno Leitao wrote:
>>    =20
>>> When I run netperf in just one interface, I get 940.95 * 10^6 bits/=
sec
>>> of transfer rate. If I run 4 netperf against 4 different interfaces=
, I
>>> get around 720 * 10^6 bits/sec.
>>>      =20
>> I hope this explanation makes sense, but what it comes down to is th=
at
>> combining hardware round robin balancing with NAPI is a BAD IDEA.  I=
n
>> general the behavior of hardware round robin balancing is bad and I'=
m
>> sure it is causing all sorts of other performance issues that you ma=
y
>> not even be aware of.
>>    =20
> I've made another test removing the ppc IRQ Round Robin scheme, bonde=
d
> each interface (eth6, eth7, eth16 and eth17) to different CPUs (CPU1,
> CPU2, CPU3 and CPU4) and I also get around around 720 * 10^6 bits/s i=
n
> average.
>
> Take a look at the interrupt table this time:=20
>
> io-dolphins:~/leitao # cat /proc/interrupts  | grep eth[1]*[67]
> 277:         15    1362450         13         14         13         1=
4         15         18   XICS      Level     eth6
> 278:         12         13    1348681         19         13         1=
5         10         11   XICS      Level     eth7
> 323:         11         18         17    1348426         18         1=
1         11         13   XICS      Level     eth16
> 324:         12         16         11         19    1402709         1=
3         14         11   XICS      Level     eth17
>
>
> I also tried to bound all the 4 interface IRQ to a single CPU (CPU0)
> using the noirqdistrib boot paramenter, and the performance was a lit=
tle
> worse.
>
> Rick,=20
>   The 2 interface test that I showed in my first email, was run in tw=
o
> different NIC. Also, I am running netperf with the following command
> "netperf -H <hostname> -T 0,8" while netserver is running without any
> argument at all. Also, running vmstat in parallel shows that there is=
 no
> bottleneck in the CPU. Take a look:=20
>
> procs -----------memory---------- ---swap-- -----io---- -system-- ---=
--cpu------
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us =
sy id wa st
>  2  0      0 6714732  16168 227440    0    0     8     2  203   21  0=
  1 98  0  0
>  0  0      0 6715120  16176 227440    0    0     0    28 16234  505  =
0 16 83  0  1
>  0  0      0 6715516  16176 227440    0    0     0     0 16251  518  =
0 16 83  0  1
>  1  0      0 6715252  16176 227440    0    0     0     1 16316  497  =
0 15 84  0  1
>  0  0      0 6716092  16176 227440    0    0     0     0 16300  520  =
0 16 83  0  1
>  0  0      0 6716320  16180 227440    0    0     0     1 16354  486  =
0 15 84  0  1
> =20
>
>  =20
If your machine has 8 cpus, then your vmstat output shows a bottleneck =
:)

(100/8 =3D 12.5), so I guess one of your CPU is full






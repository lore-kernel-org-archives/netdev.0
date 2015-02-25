From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Wed, 25 Feb 2015 13:29:47 +0800
Message-ID: <54ED5DCB.6020702@windriver.com>
References: <54DDCA99.4040401@windriver.com>	<20150213133056.3944c13e@uryu.home.lan>	<54E17853.8070106@windriver.com>	<54E210FF.2050502@gmail.com>,<20150216115137.5aa3f0cd@uryu.home.lan> <E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3@ALA-MBB.corp.ad.wrs.com> <54ED39B9.4090107@windriver.com> <54ED4E47.9070304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: David Ahern <dsahern@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33046 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbbBYF3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 00:29:40 -0500
In-Reply-To: <54ED4E47.9070304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 12:23 PM, David Ahern wrote:
> On 2/24/15 7:55 PM, yzhu1 wrote:
>> Hi, Stephen && David
>>
>> Any update?
>
> As I mentioned in my last response I see no problem with the existing 
> behavior -- 3.18, 3.19 and 4.0-rc1. With all of them the bridge stays 
> in the running state after all interfaces are removed.
>
> David
>
>
>
Hi, David

I made tests on kernel 3.19-rc7.

1. brctl addbr br0

2. ifconfig br0 up

3. ifconfig br0 (br0's status is with 'RUNNING')

br0       Link encap:Ethernet  HWaddr 0a:70:0b:06:34:8f
           inet6 addr: fe80::870:bff:fe06:348f/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:0 (0.0 B)  TX bytes:5054 (5.0 KB)

4. brctl addif br0 eth1

5. brctl delif br0 eth1

6. ifconfig br0 (br0's status is without 'RUNNING')

br0       Link encap:Ethernet  HWaddr 00:00:00:00:00:00
           inet6 addr: fe80::870:bff:fe06:348f/64 Scope:Link
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:328 errors:0 dropped:5 overruns:0 frame:0
           TX packets:19 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:39997 (39.9 KB)  TX bytes:5760 (5.7 KB)

Please compare with the outputs of step 3 and step 6, we can find the 
difference.

uname:

Linux wind-virtual-machine 3.19.0-rc7 #2 SMP Wed Jan 28 18:36:44 CST 
2015 x86_64 x86_64 x86_64 GNU/Linux

So I think we should apply the latest patch to make consistent.

Any reply is appreciated.

Zhu Yanjun

From: "Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>
Subject: RE: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Sun, 15 Feb 2015 07:49:41 +0000
Message-ID: <813DA48C685B544CA1188C3B9775C63571E47DCD@ALA-MBA.corp.ad.wrs.com>
References: <54DDCA99.4040401@windriver.com>
 <20150213133056.3944c13e@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, "Tao, Yue" <Yue.Tao@windriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Zhu, Yanjun" <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:39655 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbBOHto convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 02:49:44 -0500
In-Reply-To: <20150213133056.3944c13e@uryu.home.lan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
  When we up a bridge without sub-interfaces,  it has "RUNNING" flag as below. Is it correct or not?

1. brctl addbr br0
2. ifconfig br0 up
3. ifconfig br0 
br0 Link encap:Ethernet HWaddr e6:6c:84:a6:fc:64 
          inet6 addr: fe80::e46c:84ff:fea6:fc64/64 Scope:Link 
          UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1 
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0 
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0 
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B) TX bytes:168 (168.0 B)

Best Regards
Kuaikuai Wu

-----Original Message-----
From: Stephen Hemminger [mailto:stephen@networkplumber.org] 
Sent: Saturday, February 14, 2015 2:31 AM
To: Zhu, Yanjun
Cc: netdev; Wu, Kuaikuai; Tao, Yue
Subject: Re: If bridge have no sub-interfaces, it's status may be still with 'RUNNING'

On Fri, 13 Feb 2015 17:57:45 +0800
yzhu1 <Yanjun.Zhu@windriver.com> wrote:

> Hi, all
> 
> I made this test on ubuntu 14.04 with kernel 3,19-rc7:
> 
> 1. brctl addbr br0
> 
> 2. ifconfig br0 up
> 
> 3. ifconfig br0 (br0's status is with 'RUNNING')
> 
> 4. brctl addif br0 eth0
> 
> 5. brctl delif br0 eth0
> 
> 6. ifconfig br0 (br0's status is without 'RUNNING')
> 
> When there is no sub-interface, the flag "RUNNING" is missing after 
> the last sub-interface is removed.
> 
> As such, should we keep "RUNNING" flag after the last sub-interface is 
> removed?

This is intentional. If there are no active ports in bridge, then we want to tell applications that packets will go nowhere.

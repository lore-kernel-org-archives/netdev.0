From: David Ahern <dsahern@gmail.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Mon, 16 Feb 2015 08:47:11 -0700
Message-ID: <54E210FF.2050502@gmail.com>
References: <54DDCA99.4040401@windriver.com> <20150213133056.3944c13e@uryu.home.lan> <54E17853.8070106@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:53554 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbbBPPrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 10:47:14 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so24301098igk.1
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 07:47:13 -0800 (PST)
In-Reply-To: <54E17853.8070106@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/15/15 9:55 PM, yzhu1 wrote:
>>> 1. brctl addbr br0
>>>
>>> 2. ifconfig br0 up
>>>
>>> 3. ifconfig br0 (br0's status is with 'RUNNING')
>>>
>>> 4. brctl addif br0 eth0
>>>
>>> 5. brctl delif br0 eth0
>>>
>>> 6. ifconfig br0 (br0's status is without 'RUNNING')
>>>
>>> When there is no sub-interface, the flag "RUNNING" is missing after the
>>> last sub-interface is removed.

I do not see that behavior with Fedora 21 and 3.18.5-201.fc21.x86_64. 
ie., after interface is removed br0 is still in up state. Perhaps a 
regression with 3.19.

>>>
>>> As such, should we keep "RUNNING" flag after the last sub-interface is
>>> removed?
>> This is intentional. If there are no active ports in bridge, then
>> we want to tell applications that packets will go nowhere.

It changes current behavior with respect to tcpdump. Today I can launch 
tcpdump on a bridge interface before starting a VM. With this change I 
will not be able to do that.

David

From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sat, 10 May 2008 00:13:41 +0200
Message-ID: <4824CC95.9030106@krogh.cc>
References: <482498D5.9060008@krogh.cc>	<20080509.143229.174354251.davem@davemloft.net>	<4824C936.9000103@krogh.cc> <20080509.150756.157662019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:60564 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757255AbYEIWNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 18:13:50 -0400
In-Reply-To: <20080509.150756.157662019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Fri, 09 May 2008 23:59:18 +0200
> 
>> David Miller wrote:
>>> From: Jesper Krogh <jesper@krogh.cc>
>>> Date: Fri, 09 May 2008 20:32:53 +0200
>>>
>>>> When it works I doesnt seem to be able to get it pass 500MB/s.
>>> With this card you really need multiple cpus and multiple threads
>>> sending data through the card in order to fill the 10Gb pipe.
>>>
>>> Single connections will not fill the pipe.
>> The server is a Sun X4600 with 8 x dual-core CPU's, setup with 64
>> NFS-threads. The other end of the fiber goes into a switch with gigabit
>> ports connected to 48 dual-core cpus. The test was done doing a dd on a
>> 4.5GB file from the server to /dev/null on the clients.
> 
> A single file transfer will not fill the pipe using this card, no
> matter how many cpus you have :-)

I do run 20+ times dd on each of the clients at the same time. Using a
single client I should be able to get it pass 1 gigabit. (The 4.5 GB
file can fit in the 32GB memory of the server so the serverdisk isn't
the bottleneck either)

Further investigation shows that:
# ethtool -k eth4
Offload parameters for eth4:
Cannot get device rx csum settings: Operation not supported
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

Does that seem correct?

-- 
Jesper

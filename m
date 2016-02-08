From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Mon, 8 Feb 2016 11:15:38 +0100
Message-ID: <56B86ACA.1030704@stressinduktion.org>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com> <20160203133356.GA2219@nanopsycho.orion>
 <56B219FA.7080208@iogearbox.net> <56B35089.4000707@stressinduktion.org>
 <20160204132622.GB2198@nanopsycho.orion>
 <56B472F2.6080101@stressinduktion.org>
 <20160205173841.GA23058@ast-mbp.thefacebook.com>
 <20160206194045.GA2282@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45830 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751193AbcBHKPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 05:15:47 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 64CEB20BCF
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 05:15:46 -0500 (EST)
In-Reply-To: <20160206194045.GA2282@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 06.02.2016 20:40, Jiri Pirko wrote:
> Fri, Feb 05, 2016 at 06:38:42PM CET, alexei.starovoitov@gmail.com wrote:
>> On Fri, Feb 05, 2016 at 11:01:22AM +0100, Hannes Frederic Sowa wrote:
>>>
>>> Okay. I see it more as changing mode of operation of hardware and thus has
>>> not really anything to do with networking. If you say you change ethernet to
>>> infiniband it has something to do with networking, sure. But I am fine with
>>> this, I just thought the code size could be reduced by adding this to sysfs
>>> quite a lot. I don't have a strong opinion on this.
>>
>> there is already a way to change eth/ib via
>> echo 'eth' > /sys/bus/pci/drivers/mlx4_core/0000:02:00.0/mlx4_port1
>>
>> sounds like this is another way to achieve the same?
>
> It is. However the current way is driver-specific, not correct.

Why is driver specific not correct? Actually it is very much a device 
specific thing, isn't it?

> For mlx5, we need the same, it cannot be done in this way. Do devlink is
> the correct way to go.

Do two drivers already justify a new complete netlink api? Doesn't this 
create the same problems like netdevice naming problems which needed 
multiple years to become stable in case we have multiple cards or some 
administrator reorders the cards (biosdevorder, systemd/udev issues)? 
Are ports always stable? How can we have a 1:1 relationship with 
ifindexes and how can they be stable? It is impossible to use that in 
scripts?

>> Why not hide echo/cat in iproute2 instead of adding parallel netlink api?
>> Or this is for switches instead of nics?
>> Then why it's not adding to switchdev?
>
> Note this is not specific to switch ASICs. This is for all network devices.

That's actually my fear. The relationship from "devlink-names" to 
ifindexes I didn't understand at all architecturally.

Bye,
Hannes

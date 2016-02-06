From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Sat, 6 Feb 2016 20:40:45 +0100
Message-ID: <20160206194045.GA2282@nanopsycho.orion>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com>
 <20160203133356.GA2219@nanopsycho.orion>
 <56B219FA.7080208@iogearbox.net>
 <56B35089.4000707@stressinduktion.org>
 <20160204132622.GB2198@nanopsycho.orion>
 <56B472F2.6080101@stressinduktion.org>
 <20160205173841.GA23058@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34845 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbcBFTks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 14:40:48 -0500
Received: by mail-wm0-f66.google.com with SMTP id g62so8569363wme.2
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 11:40:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160205173841.GA23058@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 05, 2016 at 06:38:42PM CET, alexei.starovoitov@gmail.com wrote:
>On Fri, Feb 05, 2016 at 11:01:22AM +0100, Hannes Frederic Sowa wrote:
>> 
>> Okay. I see it more as changing mode of operation of hardware and thus has
>> not really anything to do with networking. If you say you change ethernet to
>> infiniband it has something to do with networking, sure. But I am fine with
>> this, I just thought the code size could be reduced by adding this to sysfs
>> quite a lot. I don't have a strong opinion on this.
>
>there is already a way to change eth/ib via
>echo 'eth' > /sys/bus/pci/drivers/mlx4_core/0000:02:00.0/mlx4_port1
>
>sounds like this is another way to achieve the same?

It is. However the current way is driver-specific, not correct.
For mlx5, we need the same, it cannot be done in this way. Do devlink is
the correct way to go.


>Why not hide echo/cat in iproute2 instead of adding parallel netlink api?
>Or this is for switches instead of nics?
>Then why it's not adding to switchdev?

Note this is not specific to switch ASICs. This is for all network devices.

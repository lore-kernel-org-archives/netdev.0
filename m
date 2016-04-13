From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v2 5/5] Add sample for adding simple drop program to
 link
Date: Wed, 13 Apr 2016 06:40:36 -0400
Message-ID: <570E2224.7050704@mojatatu.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
 <57091625.1010206@mojatatu.com> <20160409164308.GA5750@gmail.com>
 <57093B67.1080604@mojatatu.com> <20160410183810.GA18749@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, brouer@redhat.com, eric.dumazet@gmail.com,
	ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch,
	johannes@sipsolutions.net, eranlinuxmellanox@gmail.com,
	lorenzo@google.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:33953 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932776AbcDMKku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 06:40:50 -0400
Received: by mail-ig0-f195.google.com with SMTP id qu10so5978083igc.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 03:40:50 -0700 (PDT)
In-Reply-To: <20160410183810.GA18749@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-10 02:38 PM, Brenden Blanco wrote:

>> I always go for the lowest hanging fruit.
> Which to me is the 60% time spent above the driver level as shown above.
[..]
>> It seemed it was the driver path in your case. When we removed
>> the driver overhead (as demoed at the tc workshop in netdev11) we saw
>> __netif_receive_skb_core() at the top of the profile.
>> So in this case seems it was mlx4_en_process_rx_cq() - thats why i
>> was saying the bottleneck is the driver.
> I wouldn't call it a bottleneck when the time spent is additive,
> aka run-to-completion.


The driver is a bottleneck regardless. It is probably the DMA interfaces 
and lots of cacheline misses. So the first thing to
fix is whats at the top of the profile if you wanb
The fact you are dropping earlier is in itself an improvement
as long as you dont try to be too fancy.

> Of course the second perf report is on the same machine as the commit
> message. That was generated fresh for this email thread. All of the
> numbers I've quoted come from the same single-sender/single-receiver
> setup. I did also revert the change the in mlx4 driver and there was no
> change in the tc numbers.

Ok, i misunderstood then because you hinted Daniel had seen those
numbers. If you please also add that to your commit numbers.

cheers,
jamal

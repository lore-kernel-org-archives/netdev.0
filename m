From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to do TCP tx checksums
Date: Tue, 17 Nov 2015 09:19:36 -0800
Message-ID: <564B61A8.5050205@candelatech.com>
References: <564A72D3.1050407@candelatech.com>
 <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:36344 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbbKQRTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 12:19:36 -0500
In-Reply-To: <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2015 09:02 PM, Tom Herbert wrote:
> On Mon, Nov 16, 2015 at 4:20 PM, Ben Greear <greearb@candelatech.com> wrote:
>> Hello!
>>
>> I'm hacking on (my already hacked) pktgen, trying to get it to send TCP
>> frames.
>>
>> And, having issues getting checksums to work properly.
>>
>> I'm trying this:
>>          struct iphdr *iph = ip_hdr(skb);
>>          struct net_device *odev = pkt_dev->odev;
>>
>>          if (pkt_dev->flags & F_TCP) {
>>                  if (odev->features & NETIF_F_V4_CSUM) {
>>                          skb->ip_summed = CHECKSUM_PARTIAL;
>>                  } else {
>>                          skb->ip_summed = CHECKSUM_NONE;
>>                  }
>>                  skb->csum = 0;
>>                  __tcp_v4_send_check(skb, iph->saddr, iph->daddr);
>>
>> I added an export so I could call that __tcp_v4_send_check method
>> w/out having to put a fake socket struct on the stack.
>>
>> But, the receiving NIC reports 100% checksum failure, so obviously
>> I'm not doing it correct.
>>
>> Any suggestions on what I might be doing wrong or the proper method(s)
>> to call?
>>
> It's really hard to tell what is happening without seeing the full
> patch your using. Maybe you're not setting the TCP correctly or
> transport header is not set right in skb.

Unfortunately, my pktgen has diverged significantly from upstream, so
a patch is probably not so useful.

The full pktgen.[ch] files are here:

http://www.candelatech.com/~greearb/patches/

If you look for 'F_TCP' you can find the pertinent bits
that I'm mucking with.  I have changed it a bit since I last posted
the patch above...but still the receiving NIC is reporting 100%
csum failure, so I must still be doing something wrong.

I have also tweaked how UDP is done, but that seems to be working.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

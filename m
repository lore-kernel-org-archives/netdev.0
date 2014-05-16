From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] loopback: explicitly set pkt_type to PACKET_HOST
Date: Fri, 16 May 2014 10:52:09 -0700
Message-ID: <CAM_iQpVGG92NMYTJuCXg3yhCkVDyL3Tf=5HJy6n2V1Z89yySzw@mail.gmail.com>
References: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140515.163400.1536463708975272927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:51486 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755047AbaEPRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:52:09 -0400
Received: by mail-ob0-f175.google.com with SMTP id wo20so3294804obc.34
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:52:09 -0700 (PDT)
In-Reply-To: <20140515.163400.1536463708975272927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 1:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Wed, 14 May 2014 11:39:22 -0700
>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> In a corner case where I redirect the packets from veth to lo,
>> packets are dropped silently when entering IP stack. This is
>> due to we have a different MAC addr on veth, so the packets are
>> marked as PACKET_OTHERHOST. And after they are redirect to lo,
>> this value is kept since lo has the same MAC addr with the packets.
>> Loopback should explicitly set it to PACKET_HOST before calling
>> eth_type_trans() for this specific case.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>
> How exactly are you performing this redirection?

Oh, I meant using tc mirred action to redirect packets from vethX to lo.
Sorry for confusing.

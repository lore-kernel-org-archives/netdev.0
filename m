From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 5/8] net/mlx4_en: Remove redundant code from
 RX/GRO path
Date: Fri, 31 Oct 2014 16:00:07 +0200
Message-ID: <CAJ3xEMiDnv9=nvvJ1m7_taoSncdmgv4GJVR8DiD5t5GCsFig1A@mail.gmail.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	<1414685216-28907-6-git-send-email-ogerlitz@mellanox.com>
	<1414695631.15352.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJ3xEMjw9rRLBTEXT3cw0+CPRyvJgNbKVHpnmsukas-r=QwmyA@mail.gmail.com>
	<1414725541.499.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:50975 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758896AbaJaOAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 10:00:08 -0400
Received: by mail-oi0-f47.google.com with SMTP id a3so5017709oib.6
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 07:00:07 -0700 (PDT)
In-Reply-To: <1414725541.499.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2014 at 5:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-31 at 01:25 +0200, Or Gerlitz wrote:
>> On Thu, Oct 30, 2014 at 9:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2014-10-30 at 18:06 +0200, Or Gerlitz wrote:
>> >> Remove the code which goes through napi_gro_frags() on the RX path,
>> >> use only napi_gro_receive().
>>
>> > Hmpff... napi_gro_frags() should be faster.
>> > Have you benchmarked this ?
>>
>>
>> yep we did, napi_gro_frags() was somehow better for single stream. Do
>> you think we need to do it the other way around, e.g converge to use
>> napi_gro_frags()?

> napi_gro_frags() is faster because the napi->skb is reused fast (not
> going through kfree_skb()/alloc_skb() for every fragment)

I see. Is this a strong vote to convert the code to use napi_gro_frags
on it's usual track?

Or.

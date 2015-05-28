From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next 01/14] ethtool: Add helper routines to pass vf to rx_flow_spec
Date: Thu, 28 May 2015 07:34:58 -0700
Message-ID: <55672792.9030104@gmail.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com> <1432812339-17129-2-git-send-email-jeffrey.t.kirsher@intel.com> <CAJ3xEMhfzvhq-Y==LUTFg9Be9oWZZzKHEaTODeqphowpY8XLGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Alex Duyck <alexander.h.duyck@redhat.com>,
	Matan Barak <matanb@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33794 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbE1OfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:35:15 -0400
Received: by oifu123 with SMTP id u123so33701831oif.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 07:35:15 -0700 (PDT)
In-Reply-To: <CAJ3xEMhfzvhq-Y==LUTFg9Be9oWZZzKHEaTODeqphowpY8XLGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 06:18 AM, Or Gerlitz wrote:
> On Thu, May 28, 2015 at 2:25 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> From: John Fastabend <john.r.fastabend@intel.com>
>>
>> The ring_cookie is 64 bits wide which is much larger than can be used
>> for actual queue index values. So provide some helper routines to
>> pack a VF index into the cookie. This is useful to steer packets to
>> a VF ring without having to know the queue layout of the device.
>
> So this patch comes  to generalize the proprietary solution introduced
> in the below commit?
>

Well I developed it in a bit different context, but I would expect
the same mechanism to be used for i40e and any other devices that can
support this.

> commit e7c8c60bc5d48994a67e4b1c7bfb01d6979dbc54
> Author: Anjali Singhai Jain <anjali.singhai@intel.com>
> Date:   Tue Apr 7 19:45:31 2015 -0400
>
>      i40e: Add support to program FDir SB rules for VF from PF through ethtool
>
>      With this patch we can now add Flow director Sideband rules for a VF from
>      it's PF. Here is an example on how it can be done when VF id = 5 and
>      queue = 2:
>
>      "ethtool -N ethx flow-type udp4 src-ip x.x.x.x dst-ip y.y.y.y
> src-port p1 dst-port p2 action 2 user-def 5"
>
>      User-def specifies VF id and action specifies queue.
>
>
>>   include/uapi/linux/ethtool.h | 25 +++++++++++++++++++++++++
>>   1 file changed, 25 insertions(+)

[...]


-- 
John Fastabend         Intel Corporation

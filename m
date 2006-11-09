From: "Jeff V. Merkey" <jmerkey@soleranetworks.com>
Subject: Re: e1000 driver 2.6.18 - how to waste processor cycles
Date: Thu, 09 Nov 2006 15:49:30 -0700
Message-ID: <4553B07A.6050002@soleranetworks.com>
References: <45524E3A.7080301@soleranetworks.com>	 <4807377b0611081701i26ee7ce0k1f822dbbe52c2c8@mail.gmail.com>	 <4552EAFC.5060400@soleranetworks.com> <4807377b0611091445s11575f5ej15c7bf7126bb5658@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	NetDEV list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc15.comcast.net ([216.148.227.155]:47814 "EHLO
	rwcrmhc15.comcast.net") by vger.kernel.org with ESMTP
	id S1424229AbWKIXCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:02:06 -0500
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0611091445s11575f5ej15c7bf7126bb5658@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

> On 11/9/06, Jeffrey V. Merkey <jmerkey@soleranetworks.com> wrote:
>
>> In the case I am referring to, the memory is already mapped with a
>> previous call, which means it may be getting
>> mapped twice.
>
>
> I guess maybe I'm not keeping up with you.  This is what I see looking
> in 2.6.18, i see e1000_clean_rx_irq:


Check e1000_alloc_rx_buffers:

if (skb already exists in ring buffer)
  goto map_skb:
else
   dev_alloc_skb
  ( drop through to map_skb)


map_skb:
  pci_map_single

Jeff

>
> check done bit
> pci_unmap_single
> copybreak and recycle
> OR
> hand buffer up stack
>
> the only branch before the unmap is the napi break out, and in that
> case we don't change any memory state, so alloc will not do anything.
>
> As for alloc rx, we always map, because we always unmapped.
>
> Did I miss something?  I would appreciate a more detailed explanation
> of what you see going wrong.
>
>


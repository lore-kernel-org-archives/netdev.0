From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] 8139cp: allow to set mac address on running device
Date: Fri, 13 Mar 2009 12:16:34 +0100
Message-ID: <20090313111633.GB3436@psychotron.englab.brq.redhat.com>
References: <20090312162730.GA20153@psychotron.englab.brq.redhat.com> <20090312181121.79e297a2@brian.englab.brq.redhat.com> <20090312174641.GC20153@psychotron.englab.brq.redhat.com> <49BA20E1.70607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Schmidt <mschmidt@redhat.com>, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net, netdev@vger.kernel.org
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43556 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591AbZCMLQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 07:16:40 -0400
Content-Disposition: inline
In-Reply-To: <49BA20E1.70607@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 13, 2009 at 10:01:21AM CET, ivecera@redhat.com wrote:
>Jiri Pirko wrote:
>> Thu, Mar 12, 2009 at 06:11:21PM CET, mschmidt@redhat.com wrote:
>>> On Thu, 12 Mar 2009 17:27:31 +0100
>>> Jiri Pirko <jpirko@redhat.com> wrote:
>>>
>>>> +	cpw32_f(MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr +
>>>> 0)));
>>>> +	cpw32_f(MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr +
>>>> 4)));
>>> You're writing to the card, so using *_to_cpu looks suspicious.
>> Well, I'm using the same approach as it is already done in function
>> cp_init_hw(). Quote:
>> 
>>  /* Restore our idea of the MAC address. */
>>  cpw32_f (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
>>  cpw32_f (MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
>> 
>Yes, that's right but I would use more cleaner approach:
>===
>u32 low, high;
>low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
>high = addr[4] | (addr[5] << 8);
>cpw32_f(MAC0 + 0, low);
>cpw32_f(MAC0 + 4, high);
>===
Well, I have no problem with this (in fact I like this more). I just wanted to
stay consistent to existing code. Maybe it would be good to change this chunk
of code in cp_init_hw() too, don't you think?

Jirka
>
>Ivan

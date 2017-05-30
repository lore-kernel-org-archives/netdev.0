From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/7] net: dsa: hide dsa_uses_tagged_protocol code
Date: Tue, 30 May 2017 11:56:30 -0400
Message-ID: <87wp8y2v9t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com> <20170530142131.23568-2-vivien.didelot@savoirfairelinux.com> <20170530150144.GC22758@lunn.ch> <20170530.110923.2297838959849946238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52054 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdE3P6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:58:46 -0400
In-Reply-To: <20170530.110923.2297838959849946238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, David,

David Miller <davem@davemloft.net> writes:

>>> +bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
>>> +{
>>> +	return !!dst->rcv;
>>> +}
>>> +
>> 
>> You need to be careful here. This is in the hot path. Every frame
>> received uses this code. And think about a distro kernel, which might
>> have DSA enabled by default, yet is unlikely to have any switches. You
>> are adding a function call which can be called millions of times per
>> second....
>
> Yeah, we really can't make this change.
>
> This isn't glibc where we're trying to hide the implementation of "FILE *"
> behind accessor functions that caller can't see.  We inline things when
> performance dictates, and it does here.

Thanks for the explanation, this wasn't obvious to me at all. So inline
is mandatory here. Would a dereference like "!!dst->tag_ops->rcv" have
an significant impact on performance?

Thanks,

        Vivien

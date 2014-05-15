From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 3/9] bonding: make BOND_NO_USES_ARP an inline
 function
Date: Thu, 15 May 2014 17:45:27 +0200
Message-ID: <20140515154527.GA2789@mikrodark.usersys.redhat.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
 <1400156967-8231-4-git-send-email-vfalico@gmail.com>
 <CAADnVQKMKZ4dMvUXpCQiKc839+UTa7hjBh71WzADXD6vH1B48Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:44392 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbaEOPpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 11:45:51 -0400
Received: by mail-wg0-f46.google.com with SMTP id n12so3703356wgh.29
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 08:45:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQKMKZ4dMvUXpCQiKc839+UTa7hjBh71WzADXD6vH1B48Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 08:35:47AM -0700, Alexei Starovoitov wrote:
>On Thu, May 15, 2014 at 5:29 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
...snip...
>> -       if (BOND_NO_USES_ARP(bond_mode)) {
>> +       if (!bond_mode_uses_arp(bond_mode)) {
>
>looks like condition becomes inverted.
>Did you mean to add '!' inside bond_mode_uses_arp() as well?

Right, good catch. Easy to miss with this amount of mechanical work :(.

I'll wait for more feedback and resubmit v3.

Thanks!

>
...snip...
>> -#define BOND_NO_USES_ARP(mode)                         \
>> -               (((mode) == BOND_MODE_8023AD)   ||      \
>> -                ((mode) == BOND_MODE_TLB)      ||      \
>> -                ((mode) == BOND_MODE_ALB))
>> -
...snip...
>> +static inline bool bond_mode_uses_arp(int mode)
>> +{
>> +       return mode == BOND_MODE_8023AD || mode == BOND_MODE_TLB ||
>> +              mode == BOND_MODE_ALB;
>> +}
>> +
...snip...

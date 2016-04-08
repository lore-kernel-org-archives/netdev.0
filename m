From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 8 Apr 2016 09:54:00 -0700
Message-ID: <CAGXr9JED3WLEQr67FrMJoJnUaYJwOcnwRE4JxHTaf+0ha00kig@mail.gmail.com>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
	<CAGVrzcbHGq7YP6kJ+M+jM+CCsKXMoqtzkf04YHPj+kseqm__9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:34798 "EHLO
	mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287AbcDHQyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:54:02 -0400
Received: by mail-vk0-f53.google.com with SMTP id e185so145098544vkb.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:54:01 -0700 (PDT)
In-Reply-To: <CAGVrzcbHGq7YP6kJ+M+jM+CCsKXMoqtzkf04YHPj+kseqm__9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 1:25 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
> 2016-04-05 17:50 GMT-07:00 Petri Gynther <pgynther@google.com>:
> > Add Byte Queue Limits (BQL) support to bcmgenet driver.
> >
> > Signed-off-by: Petri Gynther <pgynther@google.com>
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>
> Thanks!
> --
> Florian

Any further comments?

Notable difference from some other drivers --
netdev_tx_reset_queue(txq) is called for all queues in
bcmgenet_netif_start(), just before netif_tx_start_all_queues(dev).
This is to ensure that BQL is reset before the interface becomes
operational.

I think that is the right place for these calls.

Some other drivers call it from the "interface down" path.

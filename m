From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Wed, 18 Feb 2015 14:11:09 -0800
Message-ID: <CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
	<CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:43680 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbbBRWLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 17:11:10 -0500
Received: by iebtr6 with SMTP id tr6so4931980ieb.10
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 14:11:09 -0800 (PST)
In-Reply-To: <CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2015 at 1:18 PM, Cong Wang <cwang@twopensource.com> wrote:
>
> 2) This breaks the queue mapping specified by an skbedit action,
> since for TX queues the index starts with 0 while for RX it starts with 1
> (for some reason I don't see yet). There is at least a mismatch.

So queue 0 is reserved for TX, at least for bonding queue mapping.

But for sch_mq, all queues are used, 0 is merely the default one.
This means we should still allow user to specify queue 0 for TX.

We are trying to do queue mapping for containers, queue 0 isn't
special for us at all, therefore I don't see why we should reserve it
at least for hardware TX queues.

*I think* we should use the same strategy for TX queue mapping like
RX queue mapping, where ->queue_mapping = 0 means "not set",
while ->queue_mapping maps to a real queue index starting at 0.
This would also make ->queue_mapping have the same meaning
across RX -> TX if we really need to preserve it.

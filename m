From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 7/7] net: move skb->dropcount to skb->cb[]
Date: Thu, 26 Feb 2015 17:32:18 +0200
Message-ID: <20150226173218.7c6bb2d6@halley>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-8-git-send-email-eyal.birger@gmail.com>
	<20150226104909.1f2c882d@halley>
	<CAHsH6GvEmkOZU=VngK9-yn_2ajNX2YU1aJ=qfuHby3=58r4dKw@mail.gmail.com>
	<CAHsH6Gs5JwRXgWGuC4fKaqPU3yb219z1q1K-cvn5Z6qjFOgo8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:37972 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbbBZPc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:32:27 -0500
Received: by wesw55 with SMTP id w55so11890909wes.5
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 07:32:26 -0800 (PST)
In-Reply-To: <CAHsH6Gs5JwRXgWGuC4fKaqPU3yb219z1q1K-cvn5Z6qjFOgo8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2015 12:48:14 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
> After giving it some additional thought and research, I don't think
> this is necessary.
> 
> The sizeof operator on struct sock_skb_cb would give a padded result
> which would take care of the structure alignment.
> 
> This is under the assumption that skb->cb[] size is of a proper multiple (which
> I think is rather safe).

Yes, you are correct.

With the assumption that skb->cb and 'cb' size are properly aligned and
sized (compile time asserted, btw?), you can simply:

struct your_thing {     // name it
	u32 dropcount;
};

struct sock_skb_cb {
	/* protocol families specifc CBs */
	u8 pf_reserved[PAD];
	struct your_thing sock_cb;
};

where:

#define PAD (FIELD_SIZEOF(struct sk_buff, cb) - sizeof(struct your_thing))

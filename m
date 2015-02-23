From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Mon, 23 Feb 2015 11:10:36 -0800
Message-ID: <1424718636.5565.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	 <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	 <20150223205633.7fbd08d4@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eyal Birger <eyal.birger@gmail.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:61223 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbbBWTKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:10:39 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so20913103iga.0
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 11:10:38 -0800 (PST)
In-Reply-To: <20150223205633.7fbd08d4@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-23 at 20:56 +0200, Shmulik Ladkani wrote:
> Hi,
> 
> On Mon, 23 Feb 2015 19:52:03 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
> > Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
> > unionized skb->mark and skb->dropcount in order to allow recording
> > of the socket drop count while maintaining struct sk_buff size.
> > 
> > In order to allow for the skb->mark to be fetched by user-space code
> > it needs to be detached from this union; skb->priority is used
> > instead.
> > 
> > The purpose of overloading skb->priority is solely for retaining
> > struct sk_buff size; skb->priority is not used after the skb is
> > queued to the socket.
> > 
> > Use of aliased fields, skb->dropcount and skb->reserved_tailroom,
> > is either done after the skb is cloned (e.g. in packet_rcv()) or
> > before skb->priority is used (e.g. in IGMPv3/MLD/TCP).
> 
> Preserving a small skb size is an important cause.
> 
> In this case however, it seems that aliasing 'priority' sacrifices
> maintainability: 'priority' does not seem "naturally orthogonal" to
> 'drop_count' or 'reserved_tailroom'.
> 
> One might arm 'priority' in various code flows (future and existing),
> which may accidentally clash with the aliases. It is unexpected, hard to
> remember (especially since 'priority' wasn't formerly aliased), and
> sometimes it's simply not trivial to assure there's no clash.
> 
> May I suggest to unalias 'mark' out of the union?

My suggestion would be to move dropcount in skb->cb[] instead.

mark & reserved_tailroom can stay in the union.

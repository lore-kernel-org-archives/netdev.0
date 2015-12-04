From: YanBo <dreamfly281@gmail.com>
Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863 operational state"
Date: Thu, 3 Dec 2015 18:31:19 -0800
Message-ID: <CAFuUQkjm3RFnrzWWSvbnYFC8gMnbX7C4bP_x0+2bREYumcoJyg@mail.gmail.com>
References: <CAFuUQkhHsRZMnNYBbVZU0=BcAKMEktzYgPv6oc=CMFd7MFDi6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Krishna Chaitanya <chaitanya.mgit@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Sebastian Gottschall <s.gottschall@dd-wrt.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, hostap@lists.infradead.org
To: Felix Fietkau <nbd@openwrt.org>, jouni@qca.qualcomm.com,
	kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35594 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135AbbLDCbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 21:31:20 -0500
In-Reply-To: <CAFuUQkhHsRZMnNYBbVZU0=BcAKMEktzYgPv6oc=CMFd7MFDi6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Sorry to pick up this thread again,  it looks this issue still
existed  in the newer 4.3 kernel. (The EAP frames can not be received
by wireless interface due to the bridge interface,
http://marc.info/?l=linux-wireless&m=136743495526905&w=2)

 Wonder is anyone know some update for this issue?  Currently the only
workaround is make the 4-address  AP and STA associated in security
mode firstly and then create the bridge, the renew key configuration
also need be disable at the hostapd side to  avoid renew the key at
bridge status.

Thanks
Yanbo
> On Wed, May 1, 2013 at 5:53 PM, Felix Fietkau <nbd@openwrt.org> wrote:
> >
> > On 2013-05-02 12:49 AM, Stephen Hemminger wrote:
> > > On Wed, 01 May 2013 23:06:16 +0200
> > > Felix Fietkau <nbd@openwrt.org> wrote:
> > >
> > >> On 2013-05-01 10:21 PM, Stephen Hemminger wrote:
> > >> > What about using AF_PACKET bound to underlying wireless device and the
> > >> > packet type. You can even use BPF to filter.
> > >> As far as I know, AF_PACKET only works when not binding it to the packet
> > >> type (otherwise it get stolen by the rx handler).
> > >
> > > You can do AF_PACKET and it gets handle before rx_handler.
> > If I don't bind it to a protocol, it ends up in ptype_all, if I do, it
> > ends up in &ptype_base. ptype_all is processed before the rx_handler,
> > ptype_base is processed after the rx handler.
> > Hooking into ptype_all wastes tons of CPU cycles, hooking into
> > ptype_base does not solve the problem.
> >
> > - Felix
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

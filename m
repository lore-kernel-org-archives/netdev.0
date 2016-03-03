From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Wed, 2 Mar 2016 20:45:36 -0800
Message-ID: <CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:34962 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbcCCEph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 23:45:37 -0500
Received: by mail-yw0-f178.google.com with SMTP id g127so9179797ywf.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 20:45:37 -0800 (PST)
In-Reply-To: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 29, 2016 at 2:08 PM, Mahesh Bandewar <mahesh@bandewar.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
>
> netif_receive_skb_core() dispatcher uses skb->dev device to send it
> to the packet-handlers (e.g. ip_rcv, ipv6_rcv etc). These packet
> handlers intern use the device passed to determine the net-ns to
> further process these packets.  Now with the nomination logic, the
> dispatcher will call netif_get_l3_dev() helper to select the device
> to be used for this processing. Since l3_dev is initialized to self,
> normal packet processing should not change.
>

So, if I understand your patches correctly, _logically_ the skb is still
passed into the slave's netns via dev_forward_skb() but now goes over
the iptable rules from the default netns by only changing the netns
parameter to these hooks?

That is ugly... Logically, you should still need to continue to pass
the skb upper to the stack in default netns until ip_local_deliver_finish().

So, how about adding an iptable hook in ipvlan so that skb will
continue traverse in the original stack and then moved into slave's
netns? This might be harder since logically we need an L3 entrance
to the stack.

Thoughts?

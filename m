From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 12:37:46 -0800
Message-ID: <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com>
References: <530F85AE.8060002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57277 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaB0Ui1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 15:38:27 -0500
In-Reply-To: <530F85AE.8060002@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-27 10:36 GMT-08:00 Ben Greear <greearb@candelatech.com>:
> In ath10k, it can receive msdu (in rx raw mode, at least).  These show up
> as a list of skb.  Currently they are just dropped as un-handled, and I
> need to fix this.
>
> I think I need to consolidate this list into a single skb in order to pass
> it up the stack.
>
> What is the preferred way to go about doing this?
>
> It seems I could just expand the head skb (pskb_expand_head) and copy the data from the others
> onto the end of the head skb, but maybe there is a more efficient way to go about
> doing this?

Some Ethernet drivers you would in general get multiple RX fragments
for large frames, with the first fragment containing the headers, and
then buffers of a few KiB, it is the driver responsibility to
reassemble this as a large SKB with multiple fragments (grep for
skb_fill_page_desc), would that work in your case?
-- 
Florian

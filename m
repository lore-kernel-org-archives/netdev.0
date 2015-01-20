From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/2] vxlan: Eliminate dependency on UDP socket in
 transmit path
Date: Tue, 20 Jan 2015 14:53:33 -0800
Message-ID: <CA+mtBx9p0hXP=f4pCTASM_7RXfP8t2qkGQ34iQ7-vuCq1sMAWQ@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
	<1421518700-22460-3-git-send-email-therbert@google.com>
	<20150119085938.GG20315@casper.infradead.org>
	<CA+mtBx-QVcK2yP7hwr01X-KaXedzrgMGrHH503-i5y54BPnNPA@mail.gmail.com>
	<20150120181335.GL20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:62525 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbATWxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 17:53:34 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so17305655igb.5
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 14:53:34 -0800 (PST)
In-Reply-To: <20150120181335.GL20315@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 10:13 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/20/15 at 09:29am, Tom Herbert wrote:
>> I didn't see any reason to preclude that, if it needs to be symmetric
>> in that case it can be forced at the configuration. Being able to
>> receive RCO but not have to send it to certain peers is important use
>> case. You may want to consider this also for GBP if there are cases
>> where we accept GBP from different peers, but only send it to certain
>> ones.
>
> I think asymmetric configurations are fine, in particular
> receive-only. I was reluctant to the send-only scenario initially
> as I would expect a VTEP sending RCO frames on UDP dport 8472 to
> also always be able to accept RCO frames on that port. I can't
> come up with any specific cases where this would lead to problems
> though so I have no objections.
>
> As for GBP, as processing of the policy group requires additional
> iptables or OVS rules anyway, such behaviour would be implemented
> in those rules by either ignoring the mark or dropping such frames.

It's risky from a protocol perspective to assume that sending
something will be properly ignored. Just because we're willing to
receive something, doesn't mean we necessarily want to send it--
that's the robustness principle :-)

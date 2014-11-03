From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 0/7] gue: Remote checksum offload
Date: Mon, 3 Nov 2014 13:26:27 -0800
Message-ID: <CAEP_g=88Q155PxTm9qbNVuxevqDneH3bed0nRfw1nKnZEKvMfQ@mail.gmail.com>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:55575 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752979AbaKCV0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 16:26:48 -0500
Received: by mail-qg0-f54.google.com with SMTP id q108so9669374qgd.27
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 13:26:47 -0800 (PST)
In-Reply-To: <1414882683-25484-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 1, 2014 at 3:57 PM, Tom Herbert <therbert@google.com> wrote:
> This patch set implements remote checksum offload for
> GUE, which is a mechanism that provides checksum offload of
> encapsulated packets using rudimentary offload capabilities found in
> most Network Interface Card (NIC) devices. The outer header checksum
> for UDP is enabled in packets and, with some additional meta
> information in the GUE header, a receiver is able to deduce the
> checksum to be set for an inner encapsulated packet. Effectively this
> offloads the computation of the inner checksum. Enabling the outer
> checksum in encapsulation has the additional advantage that it covers
> more of the packet than the inner checksum including the encapsulation
> headers.

Tom, I have a pretty hard time squaring this with your previous
comments on hardware offload. This looks almost identical to a
protocol-specific hardware offload to me in terms of the implications
on the stack. It actually is more invasive and less likely to scale
across protocols, so the relative cost/benefit doesn't really add up
in my mind.

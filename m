From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Does CHECKSUM_COMPLETE work at all?
Date: Sat, 22 Feb 2014 13:31:04 +0100
Message-ID: <53089888.5020307@redhat.com>
References: <CA+mtBx8safaPpcntjqT+eUQBDEOxJBoVf-a9djX_qgYsSdACeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@redhat.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbaBVMbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Feb 2014 07:31:08 -0500
In-Reply-To: <CA+mtBx8safaPpcntjqT+eUQBDEOxJBoVf-a9djX_qgYsSdACeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2014 03:11 AM, Tom Herbert wrote:
> If a driver sets CHECKSUM_COMPLETE in a packet, I don't see anywhere
> in either the Ethernet rcv path or ip_rcv where the skb->csum is being
> pulled (no *pull_rcsum calls). I believe CHECKSUM_COMPLETE means the
> checksum is over the whole packet (L2, L3, and L4), so it looks like
> TCP would never see a usable value.

Funny you ask, we had recently similar question [1]. ;) So, yes, it
should be over the whole packet as seen by Linux, and is therefore not
usable as is by protocols like TCP.

  [1] http://thread.gmane.org/gmane.linux.network/292443/

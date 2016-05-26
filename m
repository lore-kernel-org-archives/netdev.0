From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: How can I test ndo_tx_timeout()?
Date: Thu, 26 May 2016 14:34:00 -0700
Message-ID: <57476BC8.5060706@gmail.com>
References: <CAOZdJXWDp1VzCtu0PQp9m_62_2sXLZeiZqsmqb_GP71Bn1bMuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36408 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbcEZVeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 17:34:03 -0400
Received: by mail-pf0-f174.google.com with SMTP id f144so21408530pfa.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 14:34:02 -0700 (PDT)
In-Reply-To: <CAOZdJXWDp1VzCtu0PQp9m_62_2sXLZeiZqsmqb_GP71Bn1bMuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2016 01:40 PM, Timur Tabi wrote:
> Is there an easy way to test my driver's response to a
> ndo_tx_timeout() call?  That is, force dev_watchdog() to think that a
> timeout has occurred?
> 

One way to do this could be to never reclaim the SKBs you just
transmitted which could be achieved by disabling the TX completion
interrupt permanently for instance. Alternatively you might stop your tx
queue, avoid checking for this condition (netif_tx_queue_stopped..) and
still try to push SKBs and transmit them, combining the two should be
fairly effective.

There could be better ways to test that, though these would at least try
to reproduce real world scenarios where transmit flow control is broken.
-- 
Florian

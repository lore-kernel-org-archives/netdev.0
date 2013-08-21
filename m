From: Johannes Naab <jn@stusta.de>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not reordering
Date: Wed, 21 Aug 2013 17:17:06 +0200
Message-ID: <5214D9F2.90900@stusta.de>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com> <1377011469-26151-2-git-send-email-mailings@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: mailings@hupie.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stusta.mhn.de ([141.84.69.5]:32952 "EHLO
	mail.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab3HUPXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 11:23:53 -0400
In-Reply-To: <1377011469-26151-2-git-send-email-mailings@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2013 05:11 PM, Ferry Huberts wrote:
> From: Ferry Huberts <ferry.huberts@pelagic.nl>
> 
> Not doing this (current behaviour) introduces reordering.
> 
> The packet_len_2_sched_time call is the only thing that logically
> depends on q->rate, so move the now/delay adjustment out of the if.
> 
> Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
> ---

Hi,

The documentation for netem does explicitly mention the reordering with
jitter, and gives instructions on how to avoid it. (I have not tested if
it works as intended).

http://www.linuxfoundation.org/collaborate/workgroups/networking/netem#How_to_reorder_packets_based_on_jitter.3F

Could you test if that fixes your problem already?


Assuming that the documentation is right:

For the sake of stability I strongly oppose changing existing and
documented behavior without opt-in. (Then again I'm not involved in
kernel development.)

If the documentation turns out to be wrong:

The netem rate extension (with all the reordering changes for that case,
which are needed for proper rate emulation in that model) was introduced
in 3.3 by Hagen Paul Pfeifer
http://marc.info/?l=linux-netdev&m=132215646820338&w=2. You could ping
him, and try to get his input/Acked-by on your patch. I only did some
bug fixing in 3.8 http://marc.info/?l=linux-netdev&m=135897762224399&w=2.

Best regards,

Johannes
-- 

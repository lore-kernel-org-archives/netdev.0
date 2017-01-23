From: Jason Baron <jbaron@akamai.com>
Subject: Re: wrong smp_mb__after_atomic() in tcp_check_space() ?
Date: Mon, 23 Jan 2017 11:56:18 -0500
Message-ID: <f5f9c542-2b23-9df9-098c-ad4007bf7e78@akamai.com>
References: <20170123143025.GA31676@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert.xu@redhat.com>,
        Yauheni Kaliuta <yauheni.kaliuta@redhat.com>,
        netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Oleg Nesterov <oleg@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:20202 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750713AbdAWQ4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:56:20 -0500
In-Reply-To: <20170123143025.GA31676@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2017 09:30 AM, Oleg Nesterov wrote:
> Hello,
>
> smp_mb__after_atomic() looks wrong and misleading, sock_reset_flag() does the
> non-atomic __clear_bit() and thus it can not guarantee test_bit(SOCK_NOSPACE)
> (non-atomic too) won't be reordered.
>

Indeed. Here's a bit of discussion on it:
http://marc.info/?l=linux-netdev&m=146662325920596&w=2

> It was added by 3c7151275c0c9a "tcp: add memory barriers to write space paths"
> and the patch looks correct in that we need the barriers in tcp_check_space()
> and tcp_poll() in theory, so it seems tcp_check_space() needs smp_mb() ?
>

Yes, I think it should be upgraded to an smp_mb() there. If you agree 
with this analysis, I will send a patch to upgrade it. Note, I did not 
actually run into this race in practice.

Thanks,

-Jason

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Reported regression against commit a05d2ad
Date: Tue, 21 Jun 2011 13:54:54 -0700
Message-ID: <m1hb7inbvl.fsf@fess.ebiederm.org>
References: <20110621201528.GB2249@herton-IdeaPad-Y430>
	<4E01015A.2030709@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>,
	lamont@canonical.com, sconklin@canonical.com,
	netdev@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45787 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751Ab1FUUzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:55:03 -0400
In-Reply-To: <4E01015A.2030709@canonical.com> (Tim Gardner's message of "Tue,
	21 Jun 2011 14:38:50 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tim Gardner <tim.gardner@canonical.com> writes:

> On 06/21/2011 02:15 PM, Herton Ronaldo Krzesinski wrote:
>> Hi,
>>
>> after update to one of the latest 2.6.32.x stable kernels for Ubuntu, we
>> got a regression report about timeout in tcp connections
>> (https://launchpad.net/bugs/791512).
>>
>> We tried help reporter with a bisect process, but it was taking some
>> time, so we reverted some suspect commits, until we isolated it to
>> commit "af_unix: Only allow recv on connected seqpacket sockets."
>>
>> With only commit a05d2ad reverted, testing results so far indicate the
>> issue doesn't happen.
>>
>> I'm unfamiliar with unix sockets code, so can't see at first why this
>> commit in particular is causing problems, for now I can only say may be
>> something at application level using unix sockets regressed with it (?).
>> I'm just reporting it right now, and we plan to revert it for that kernel
>> until more info is found about it.
>>
>> I'm adding reporter to CC (Lamont), in case more details are necessary
>> etc.
>>
>
> I believe we're also homing in on the same regression in 2.6.38.6 ('af_unix:
> Only allow recv on connected seqpacket sockets.'). The functional part of the
> patch is:
>
> +
> +       if (sk->sk_state != TCP_ESTABLISHED)
> +               return -ENOTCONN;
> +
> +       return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
>
> What happens with out of order receives? Would fragmentation have an
> impact?

That code path has absolutely nothing to do with packets that come in
over the wire.  Zilch, zero, nada.  Fragments don't matter because
fragments can not possibly hit that code path.  IP packets can not
possibly hit that code path.

Eric

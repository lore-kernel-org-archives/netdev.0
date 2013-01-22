From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 14:30:30 -0800
Message-ID: <CALnjE+qgYP50ONksYbF2uT1iLSPQ=jvOhsh72uFDoTXGTemJ2g@mail.gmail.com>
References: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
	<1358892199.12374.139.camel@edumazet-glaptop>
	<20130122.170826.1481012610894653735.davem@davemloft.net>
	<1358892924.12374.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:49239 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753350Ab3AVWac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:30:32 -0500
Received: by mail-vb0-f69.google.com with SMTP id ff20so3292187vbb.8
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 14:30:31 -0800 (PST)
In-Reply-To: <1358892924.12374.157.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 2:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-01-22 at 17:08 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 22 Jan 2013 14:03:19 -0800
>>
>> > An application changing data provided on a sendfile() or vmsplice() cant
>> > really expect data integrity being respected, even if checksum are done
>> > by the NIC (TSO)
>> >
>> > So if data integrity is not respected, just send a bogus TX checksum.
>>
>> I disagree.
>>
>> As a quality of implementation decision, we should always compute
>> correct checksums, ragardless of whether the page contents can be
>> modified asynchronously during the packet transmit.
>
> The retransmits will compute the correct checksums.
>
> For a very unlikely operation from the user, we want to disable GSO on
> GRE.
>
> If so, just revert my GSO patch.
>
> This is plain stupid to cook GSO packets and then linearize them, adding
> an extra copy and a point of failure, as allocating a 128K skb->head
> will probably fail very easily.
>
OK.
This overhead can be avoided with GRE segmentation offload. I will
send that series soon.

> Now, tcp_sendmsg() cooked skb are fine, and this patch assumes they are
> not.
>
> This patch is absolutely wrong.
>
>

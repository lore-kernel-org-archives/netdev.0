From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: filter: use block statements in tcpdump
 tests
Date: Tue, 27 May 2014 19:00:13 +0200
Message-ID: <5384C49D.7090101@redhat.com>
References: <1401128255-6545-1-git-send-email-dborkman@redhat.com> <1401128255-6545-3-git-send-email-dborkman@redhat.com> <CAMEtUuwDsabgox593uiDNocBgLo=LFE34ByqLkF0iA+F7X=boQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217AbaE0RAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 13:00:18 -0400
In-Reply-To: <CAMEtUuwDsabgox593uiDNocBgLo=LFE34ByqLkF0iA+F7X=boQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2014 08:20 AM, Alexei Starovoitov wrote:
...
>> +                       BPF_STMT(BPF_ALU | BPF_LSH | BPF_K, 2),
>> +                       BPF_STMT(BPF_MISC | BPF_TAX, 0x5), /* libpcap emits K on TAX */
>
> interesting observation. It means that libpcap doesn't init memory
> properly and other fields just have junk in them?
> and because it was doing it forever we need to accept such 'valid'
> instructions? Oh well. ok.

Hmm, doesn't look like totally random. Perhaps they're
storing some intermediate value in it or something, and
don't clear that out as we have accepted that since ever,
but that shouldn't do anything anyway here. ;)

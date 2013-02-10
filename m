From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Mon, 11 Feb 2013 00:05:32 +0900
Message-ID: <5117B73C.10600@linux-ipv6.org>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com> <51177B15.3030405@linux-ipv6.org> <51179714.6010706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:34954 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755649Ab3BJPFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 10:05:34 -0500
In-Reply-To: <51179714.6010706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Stephan Gatzka wrote:
> 
>> I have tested against MacOS X 10.5.8.
>>
>> ARP and ping works but unfortunately NDP does not seem to work.
>>
>> If I assign static NDP entry on Linux, ping6 ff02::1%fw0 from MacOS
>> works well.icmp
>>
>> I checked tcpdump on both side, and I guess this is because MacOS is
>> broken; - tcpdump on Linux side complains that ICMP checksum is
>> incorrect. - tcpdump on MacOS side says that length of Link-layer
>> address option is 2 (16) instead of 3 (24).
> 
> Than I would assume that there is a bug in your new implementation.
> RFC3146 section 8 states that the link layer option is of length 3. In
> addition, my proof of concept implementation also worked with MacOS X
> and I double checked the ndisc packets directly on the firewire line
> using a firewire sniffing device (firespy).

Can I have you code?

I meant, on MacOS X, it reports its originating lladdr option of 16bytes.
Then Linux side receives lladdr option of 24bytes, in ICMPv6 with incorrect
checksum.  I guess that lladdr option is 16byte long at bpf layer,
and then, it is mangled in the driver, but ICMPv6 checksum was not modified.

In reverse, on Linux side, it sends lladdr option of 24 bytes long
with correct checksum, but it is ignored by MacOS.

--yoshfuji

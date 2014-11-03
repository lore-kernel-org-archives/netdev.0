From: Zoltan Kiss <zoltan.kiss@linaro.org>
Subject: Re: [Xen-devel] [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Mon, 03 Nov 2014 18:23:03 +0000
Message-ID: <5457C807.5080509@linaro.org>
References: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>	<1415036346.1411.3.camel@citrix.com> <5457BF80.2000205@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:58451 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbaKCSXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 13:23:07 -0500
Received: by mail-wg0-f42.google.com with SMTP id k14so11803500wgh.15
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 10:23:06 -0800 (PST)
In-Reply-To: <5457BF80.2000205@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/11/14 17:46, David Vrabel wrote:
> On 03/11/14 17:39, Ian Campbell wrote:
>> On Mon, 2014-11-03 at 17:23 +0000, David Vrabel wrote:
>>> From: Malcolm Crossley <malcolm.crossley@citrix.com>
>>>
>>> Unconditionally pulling 128 bytes into the linear buffer is not
>>> required. Netback has already grant copied up-to 128 bytes from the
>>> first slot of a packet into the linear buffer. The first slot normally
>>> contain all the IPv4/IPv6 and TCP/UDP headers.
>>
>> What about when it doesn't? It sounds as if we now won't pull up, which
>> would be bad.
>
> The network stack will always pull any headers it needs to inspect (the
> frag may be a userspace page which has the same security issues as a
> frag with a foreign page).
I wouldn't bet my life on this, but indeed it should always happen.

>
> e.g., see skb_checksum_setup() called slightly later on in netback.
Fortunately the call to checksum_setup a bit later makes sure that at 
least the TCP/UDP headers are in the linear area, which is quite the 
same as blindly pulling 128 bytes. With any other protocol we rely on 
the network stack that it will enforce packet header in the linear buffer.

Regards,

Zoli

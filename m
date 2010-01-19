From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Tue, 19 Jan 2010 10:30:10 +0100
Message-ID: <4B557BA2.7080407@trash.net>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B5578A5.50705@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson wrote:
> Simon Arlott wrote:
>> The check for data only needs to apply where the packet length
>> could be increased by adding the MSS option. (The MSS option
>> itself applies to the sender's maximum receive size which is
>> not relevant to any data in its own packet.)
>>
>> This moves the check for (header size != packet size) to after
>> attempting to modify an existing MSS option. Another check is
>> needed before looking through the header to ensure it doesn't
>> claim to be larger than the packet size.
>>
> What's the path from tcp_v[4,6]_rcv() to these tests?
> 
> 1) Header larger than the packet is already tested in about 5 places,
> and my patch "tcp: harmonize tcp_vx_rcv header length assumptions"
> tries to get them all down to just *one* test.

We're talking about a netfilter module here, which has to deal
with forwarded traffic and can only rely on the IP header checks
done in ip_rcv().

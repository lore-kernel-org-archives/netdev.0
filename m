From: Saurabh Mohan <saurabh@cplanenetworks.com>
Subject: Re: [PATCH net-next 1/2] Support outside netns for tunnels.
Date: Thu, 7 Jan 2016 10:59:01 -0800
Message-ID: <568EB575.6010309@cplanenetworks.com>
References: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com> <568BF38D.4060803@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <nicolas.dichtel@6wind.com>, <netdev@vger.kernel.org>,
	<stephen@networkplumber.org>, <davem@davemloft.net>,
	<pshelar@nicira.com>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0120.outbound.protection.outlook.com ([65.55.169.120]:57152
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751534AbcAGUbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 15:31:39 -0500
In-Reply-To: <568BF38D.4060803@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2016 08:47 AM, Nicolas Dichtel wrote:
> Le 04/01/2016 19:45, Saurabh Mohan a =C3=A9crit :
>>
>> This patch enchances a tunnel interface, like gre, to have the tunne=
l
>> encap/decap be in the context of a network namespace that is differe=
nt from
>> the namespace of the tunnel interface.
>>
>>   From userspace this feature may be configured using the new 'onetn=
s' keyword:
>> ip netns exec custa ip link add dev tun1 type gre local 10.0.0.1 \
>>    remote 10.0.0.2 onetns outside
>>
>> In the above example the tunnel would be in the 'custa' namespace an=
d the
>> tunnel endpoints would be in the 'outside' namespace.
> What is the difference with the following commands?
>
> ip netns exec outside ip link add dev tun1 type gre local 10.0.0.1 \
>      remote 10.0.0.2
> ip netns exec outside ip link set tun1 netns custa
>
> or
>
> ip exec custa ip netns set outside 1234
> ip exec custa ip link add tun1 link-netnsid 1234 type gre local 10.0.=
0.1 \
>      remote 10.0.0.2
>
>

these methods would be functionally equivalent to what this patch does.
no point in adding a third way to do the same.

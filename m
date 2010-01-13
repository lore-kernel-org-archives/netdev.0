From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Wed, 13 Jan 2010 05:36:29 +0100
Message-ID: <m2r5puipte.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Samir Bellabes wrote:
>> +++ b/security/snet/include/snet_netlink.h
>> +
>> +struct snet_sock_half {
>> +	struct {
>> +		union {
>> +			__be32 ip;
>> +			struct in6_addr ip6;
>> +		};
>> +	} u3;
>> +	struct {
>> +		__be16 port;
>> +	} u;
>> +};
>> +
>> +struct snet_sock_info {
>> +	struct snet_sock_half src;
>> +	struct snet_sock_half dst;
>> +	int type;
>> +};
>
> How about using a struct sockaddr or encoding the values within
> netlink attributes? That would provide a bit more flexibility in
> case you want to support more protocols in the future.

indeed, I already move to the encoding of values independantly within
netlink attributes. This had to be done before, and it was in the
TODO, so now it's done. 

At first, I tried to use a attribute NLA_BINARY with all the datas
inside snet_sock_info, so it won't break the netlink protocol between
userspace and kernel, at each modification (adding/removing element
inside the structure) 

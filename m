From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: unix: inherit SOCK_PASS{CRED,SEC} flags from
 socket to fix race
Date: Fri, 18 Oct 2013 10:42:17 +0200
Message-ID: <5260F469.5060601@redhat.com>
References: <cover.1382042286.git.dborkman@redhat.com> <5c4eda258a6d7397a180ca72562b0ce5d87beda1.1382042286.git.dborkman@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7395@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab3JRIm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 04:42:26 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7395@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2013 10:26 AM, David Laight wrote:
>> Subject: [PATCH net] net: unix: inherit SOCK_PASS{CRED,SEC} flags from socket to fix race
>>
>> In the case of credentials passing in unix stream sockets (dgram
>> sockets seem not affected), we get a rather sparse race after
>> commit 16e5726 ("af_unix: dont send SCM_CREDENTIALS by default").
> ...
>> +static void unix_sock_inherit_flags(const struct socket *old,
>> +				    struct socket *new)
>> +{
>> +	if (test_bit(SOCK_PASSCRED, &old->flags))
>> +		set_bit(SOCK_PASSCRED, &new->flags);
>> +	if (test_bit(SOCK_PASSSEC, &old->flags))
>> +		set_bit(SOCK_PASSSEC, &new->flags);
>> +}
>> +
>
> Isn't that just:
> 	new->flags |= old->flags & (PASSCRED | SOCK_PASSSEC);

Nope, please have a look at the individual test_bit() etc
implementations under arch/, and the definitions of
SOCK_PASSCRED and SOCK_PASSSEC.

I though about just setting new->flags = old->flags, but that
would probably be _not_ a good idea, as we actually do not want
to pass other flags than these two relevant ones onwards.

> 	David

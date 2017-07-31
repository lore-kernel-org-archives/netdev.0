From: Florian Lehner <dev@der-flo.net>
Subject: Re: [PATCH] ss: Enclose IPv6 address in brackets
Date: Mon, 31 Jul 2017 20:17:43 +0200
Message-ID: <43a01cd8-37e9-3687-47f0-9d2d6e3e78d6@der-flo.net>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
 <20170731103010.GU16375@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:45458 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750967AbdGaSRp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 14:17:45 -0400
In-Reply-To: <20170731103010.GU16375@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2017 12:30 PM, Phil Sutter wrote:
> On Sat, Jul 29, 2017 at 02:29:10PM +0200, Florian Lehner wrote:
>> This patch adds support for RFC2732 IPv6 address format with brackets
>> for the tool ss. So output for ss changes from
>> 2a00:1450:400a:804::200e:443 to [2a00:1450:400a:804::200e]:443 for IPv6
>> addresses with attached port number.
>>
>> Signed-off-by: Lehner Florian <dev@der-flo.net>
>> ---
>>  misc/ss.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/misc/ss.c b/misc/ss.c
>> index 12763c9..db39c93 100644
>> --- a/misc/ss.c
>> +++ b/misc/ss.c
>> @@ -1059,7 +1059,11 @@ static void inet_addr_print(const inet_prefix *a,
>> int port, unsigned int ifindex
>>  			ap = format_host(AF_INET, 4, a->data);
>>  		}
>>  	} else {
>> -		ap = format_host(a->family, 16, a->data);
>> +		if (a->family == AF_INET6) {
>> +			sprintf(buf, "[%s]", format_host(a->family, 16, a->data));
>> +		} else {
>> +			ap = format_host(a->family, 16, a->data);
>> +		}
>>  		est_len = strlen(ap);
>>  		if (est_len <= addr_width)
>>  			est_len = addr_width;
> 
> Note that this will enclosed resolved hostnames in brackets as well, not
> sure if that's intended. Looks like fixing that is not exactly trivial:
> Hostname resolution is buried in format_host() which resides in
> lib/utils.c so is shared code with ip, tc, etc. Hence, adding the
> brackets in rt_addr_n2a_r() is not an option, either. Adding a 'bool *'
> param to format_host() and format_host_r() indicating that name
> resolution has happened might help here.
> 
> Cheers, Phil
> 

By adding a check in the if statement on the global variable
$resolve_hosts the resolved hostnames will not enclosed with brackets.

From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 1/4] SUNRPC: use passed network namespace context in rpc_parse_scope_id()
Date: Mon, 12 Dec 2011 20:03:45 +0400
Message-ID: <4EE625E1.7000502@parallels.com>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6> <20111207112016.17273.44510.stgit@localhost6.localdomain6> <20111208204749.GC32505@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111208204749.GC32505@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

09.12.2011 00:47, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, Dec 07, 2011 at 03:20:16PM +0300, Stanislav Kinsbursky wrote:
>> Use incomming network context in rpc_parse_scope_id() instead of har=
d-coded
>
> Changelogs are a little confusing; I might have said "allow
> rpc_parse_cope_id() caller to pass in network context instead of usin=
g
> hard-code "init_net"."
>

Hi, Bruce.
Probably, you variant is better. My English is not good enough to write=
=20
descriptive and, in the same time, clear and short comments to patches.

> --b.
>
>> "init_net".
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   net/sunrpc/addr.c |    9 +++++----
>>   1 files changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
>> index 67a655e..35eb188 100644
>> --- a/net/sunrpc/addr.c
>> +++ b/net/sunrpc/addr.c
>> @@ -156,8 +156,9 @@ static size_t rpc_pton4(const char *buf, const s=
ize_t buflen,
>>   }
>>
>>   #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>> -static int rpc_parse_scope_id(const char *buf, const size_t buflen,
>> -			      const char *delim, struct sockaddr_in6 *sin6)
>> +static int rpc_parse_scope_id(struct net *net, const char *buf,
>> +			      const size_t buflen, const char *delim,
>> +			      struct sockaddr_in6 *sin6)
>>   {
>>   	char *p;
>>   	size_t len;
>> @@ -177,7 +178,7 @@ static int rpc_parse_scope_id(const char *buf, c=
onst size_t buflen,
>>   		unsigned long scope_id =3D 0;
>>   		struct net_device *dev;
>>
>> -		dev =3D dev_get_by_name(&init_net, p);
>> +		dev =3D dev_get_by_name(net, p);
>>   		if (dev !=3D NULL) {
>>   			scope_id =3D dev->ifindex;
>>   			dev_put(dev);
>> @@ -213,7 +214,7 @@ static size_t rpc_pton6(const char *buf, const s=
ize_t buflen,
>>   	if (in6_pton(buf, buflen, addr, IPV6_SCOPE_DELIMITER,&delim) =3D=3D=
 0)
>>   		return 0;
>>
>> -	if (!rpc_parse_scope_id(buf, buflen, delim, sin6))
>> +	if (!rpc_parse_scope_id(&init_net, buf, buflen, delim, sin6))
>>   		return 0;
>>
>>   	sin6->sin6_family =3D AF_INET6;
>>


--=20
Best regards,
Stanislav Kinsbursky

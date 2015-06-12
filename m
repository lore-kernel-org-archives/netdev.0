From: Firo Yang <firogm@gmail.com>
Subject: Re: [RFC PATCH] net: Add sock_common_listen for TCP and DCCP
Date: Fri, 12 Jun 2015 10:12:18 +0800
Message-ID: <20150612021218.GA3930@firo>
References: <1434020703-7614-1-git-send-email-firogm@gmail.com>
 <1434032743.27504.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, gerrit@erg.abdn.ac.uk,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	herbert@gondor.apana.org.au, ast@plumgrid.com, dborkman@redhat.com,
	ebiederm@xmission.com, dan.carpenter@oracle.com,
	Julia.Lawall@lip6.fr, kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434032743.27504.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 11, 2015 at 07:25:43AM -0700, Eric Dumazet wrote:
>On Thu, 2015-06-11 at 19:05 +0800, Firo Yang wrote:
>> Code refactoring:
>> 1. Move the common code of inet_listen() and inet_dccp_listen() to
>> sock_common_listen().
>> Add new state SOCK_LISTEN and SOCK_CLOSE for sock_common_listen().
>> 
>> 2. Modify and rename inet_listen() to tcp_listen().
>> 
>> 3. Modify and rename inet_dccp_listen() to dccp_listen().
>> 
>> 4. Add new callback pointer listen in struct proto for
>> tcp_listen() and dccp_listen().
>> 
>> This patch makes codes more modularized and removes redudant codes.
>> 
>> Signed-off-by: Firo Yang <firogm@gmail.com>
>> ---
>> I test it on my x86 pc.
>> 
>>  include/net/sock.h  | 18 ++++++++++++++++
>>  include/net/tcp.h   |  1 +
>>  net/core/sock.c     | 36 +++++++++++++++++++++++++++++++
>>  net/dccp/dccp.h     |  2 +-
>>  net/dccp/ipv4.c     |  4 ++--
>>  net/dccp/ipv6.c     |  3 ++-
>>  net/dccp/proto.c    | 62 ++++++++++++++++-------------------------------------
>>  net/ipv4/af_inet.c  | 58 +------------------------------------------------
>>  net/ipv4/tcp.c      | 35 ++++++++++++++++++++++++++++++
>>  net/ipv4/tcp_ipv4.c |  1 +
>>  net/ipv6/af_inet6.c |  2 +-
>>  net/ipv6/tcp_ipv6.c |  1 +
>>  12 files changed, 118 insertions(+), 105 deletions(-)
>> 
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 26c1c31..5adc7f4 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -934,6 +934,7 @@ struct proto {
>>  	int			(*connect)(struct sock *sk,
>>  					struct sockaddr *uaddr,
>>  					int addr_len);
>> +	int			(*listen)(struct sock *sk, int backlog);
>>  	int			(*disconnect)(struct sock *sk, int flags);
>>  
>>  	struct sock *		(*accept)(struct sock *sk, int flags, int *err);
>> @@ -1349,6 +1350,21 @@ void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
>>  #define SOCK_BINDADDR_LOCK	4
>>  #define SOCK_BINDPORT_LOCK	8
>>  
>> +/*
>> + * Sock common state
>> + * These values must be enqual to correspondent TCP state
>> + * and DCCP state.
>> + */
>> +enum {
>> +	SOCK_CLOSE	= TCP_CLOSE,
>> +	SOCK_LISTEN	= TCP_LISTEN
>> +};
>> +
>> +enum {
>> +	SOCKF_CLOSE	= TCPF_CLOSE,
>> +	SOCKF_LISTEN	= TCPF_LISTEN,
>> +};
>> +
>
>You know, TCP_CLOSE and TCP_LISTEN are really legacy states for
>sk_state, this is not going to change anytime soon.
>
>
>I prefer to keep using TCP_xxxx names and not adding aliases.

Many thanks, Eric. I will update the patch.

Firo
>
>Otherwise your patch looks fine to me, thanks.
>
>
>

-- 

From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] sctp: jsctp_sf_eat_sack: fix kernel NULL ptr dereference
Date: Fri, 14 Dec 2012 17:57:53 +0100
Message-ID: <50CB5A91.90404@redhat.com>
References: <cover.1355494956.git.dborkman@redhat.com> <2813cf01509e495fee13ff1fab309f1186c0e57a.1355494956.git.dborkman@redhat.com> <50CB41F2.7040403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756224Ab2LNQ55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 11:57:57 -0500
In-Reply-To: <50CB41F2.7040403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2012 04:12 PM, Vlad Yasevich wrote:
> On 12/14/2012 09:27 AM, Daniel Borkmann wrote:
>> During debugging a sctp problem, I hit a kernel NULL pointer
>> dereference in the jprobes callback jsctp_sf_eat_sack(). This
>> small patch fixes the panic.
>>
>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   net/sctp/probe.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
>> index bc6cd75..0a4e9d6 100644
>> --- a/net/sctp/probe.c
>> +++ b/net/sctp/probe.c
>> @@ -134,7 +134,7 @@ sctp_disposition_t jsctp_sf_eat_sack(const struct sctp_endpoint *ep,
>>
>>       sp = asoc->peer.primary_path;
>>
>> -    if ((full || sp->cwnd != lcwnd) &&
>> +    if (sp && (full || sp->cwnd != lcwnd) &&
>>           (!port || asoc->peer.port == port ||
>>            ep->base.bind_addr.port == port)) {
>>           lcwnd = sp->cwnd;
>
> Sorry, but this patch isn't making much sense.  @sp points to the primary path of the association and that can not be null if we receiving
> SACKs on this association.
>
> sctp_sf_eat_sack_6_2(), which we are probing, is only called while the association is valid and all the transports still exist.  It is also called under lock, so the transports can not go away while processing of the SACK.  So unless there is some kind of jprobe issue, the pointer
> you are looking at should always be valid.

Okay, I'll dig a bit deeper into that over the weekend.

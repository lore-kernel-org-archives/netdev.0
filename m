From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 12:07:53 -0500
Message-ID: <52FA58E9.906@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:49216 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbaBKRHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:07:55 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar20so4723186iec.38
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 09:07:54 -0800 (PST)
In-Reply-To: <52F8FEF1.60407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/14 11:31, Vlad Yasevich wrote:
> On 02/09/2014 10:06 AM, Jamal Hadi Salim wrote:


>> +	ndm = nlmsg_data(cb->nlh);
>> +	if (ndm->ndm_ifindex) {
>
> We get really lucky here that ndm_ifindex and ifi_index happen to map to
> the same location.
>

Didnt follow - but I have a feeling you are looking at the reference
point of a bridge port.
Note as per my response to John: The target is a bridge device, not
a bridge port.



>
> I agree with both of Johns commens fro the above code.
> I think you can use ndo_dflt_fdb_dump() here and remove the first check
> for IFF_EBRIDGE.
>

Same comment i made to John. The goal is to emulate
brctl showmacs <bridge>
ndo_dflt_fdb_dump() gives me in theory all the bridge ports
unicast and multicast MAC addresses. There is a posibility that
the bridgeport is a bridge - in which case I can find out from
user space and safely request for it directly instead of via
its parent.

> The only odd thing is that it would permit syntax like:
>   # bridge fbd show br eth0
> or
>   # bridge fdb show br macvlan0
>
> but I think that's ok.

Ok, since both you and John point to macvlan - is that
considered as something with an fdb? It doesnt forward
packets between two devices.



>> diff --git a/bridge/fdb.c b/bridge/fdb.c
>> index e2e53f1..f3073d6 100644
>> --- a/bridge/fdb.c
>> +++ b/bridge/fdb.c
>> @@ -33,7 +33,7 @@ static void usage(void)
>>   	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace }
> ADDR dev DEV {self|master} [ temp ]\n"
>>   		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
>>   		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
>> -	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
>> +	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ dev DEV ]\n");
>
> 'port' option is now allowed in the show operation
>

Thanks - it is already taken seems by vxlan using the same interface.


cheers,
jamal

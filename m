From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next] be2net: do external loopback test only when
 it is requested
Date: Wed, 05 Mar 2014 11:56:16 +0100
Message-ID: <531702D0.8020205@redhat.com>
References: <1393956295-25436-1-git-send-email-ivecera@redhat.com> <531634F1.4070109@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872AbaCEK4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 05:56:22 -0500
In-Reply-To: <531634F1.4070109@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2014 09:17 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 03/04/2014 09:04 PM, Ivan Vecera wrote:
>
>> Cc: sathya.perla@emulex.com
>> Cc: subbu.seetharaman@emulex.com
>> Cc: ajit.khaparde@emulex.com
>
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>> ---
>>   drivers/net/ethernet/emulex/benet/be_ethtool.c | 9 ++++++---
>>   1 file changed, 6 insertions(+), 3 deletions(-)
>
>> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c
>> b/drivers/net/ethernet/emulex/benet/be_ethtool.c
>> index cf09d8f..957848f 100644
>> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
>> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
>> @@ -809,9 +809,12 @@ be_self_test(struct net_device *netdev, struct
>> ethtool_test *test, u64 *data)
>>                           &data[1]) != 0) {
>>               test->flags |= ETH_TEST_FL_FAILED;
>>           }
>> -        if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
>> -                        &data[2]) != 0) {
>> -            test->flags |= ETH_TEST_FL_FAILED;
>> +        if (test->flags & ETH_TEST_FL_EXTERNAL_LB) {
>> +            if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
>> +                         &data[2]) != 0) {
>> +                test->flags |= ETH_TEST_FL_FAILED;
>> +            }
>
>     {} not needed here, according to Documentation/CodingStyle. I'm
> surprised scripts/checkpatch.pl passed, it used to catch those.
>
I wanted to preserve the same look as for other prior loopback 
if-blocks. I will fix them all and resend v2.

Ivan

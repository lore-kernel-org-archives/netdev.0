From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Mon, 14 Mar 2016 23:37:00 -0700
Message-ID: <56E7AD8C.5000701@cumulusnetworks.com>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com> <DB5PR05MB1029A3A82E19D675570A36ACDB880@DB5PR05MB1029.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>
To: Elad Raz <eladr@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35753 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbcCOGhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 02:37:03 -0400
Received: by mail-pf0-f174.google.com with SMTP id n5so15243617pfn.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 23:37:02 -0700 (PDT)
In-Reply-To: <DB5PR05MB1029A3A82E19D675570A36ACDB880@DB5PR05MB1029.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/14/16, 8:11 AM, Elad Raz wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Roopa Prabhu
>> Sent: Sunday, March 13, 2016 3:56 AM
>> To: netdev@vger.kernel.org
>> Cc: jhs@mojatatu.com; davem@davemloft.net
>> Subject: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message to
>> dump link stats
>>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
[snip]
>> Future possible new types of stat attributes:
>> - IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
>> - IFLA_EXTENDED_STATS (nested. extended software netdev stats like
>> bridge,
>>   vlan, vxlan etc)
>> - IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>>   available via ethtool today)
>>
>> This patch also declares a filter mask for all stat attributes.
>> User has to provide a mask of stats attributes to query. This will be
>> specified in a new hdr 'struct if_stats_msg' for stats messages.
>>
>> Without any attributes in the filter_mask, no stats will be returned.
>>
>> This patch has been tested with modified iproute2 ifstat.
>>
>> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>  
[snip]
>> diff --git a/include/uapi/linux/rtnetlink.h
>> b/include/uapi/linux/rtnetlink.h index ca764b5..2bbb300 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -139,6 +139,13 @@ enum {
>>  	RTM_GETNSID = 90,
>>  #define RTM_GETNSID RTM_GETNSID
>>
>> +	RTM_NEWSTATS = 92,
>> +#define RTM_NEWSTATS RTM_NEWSTATS
> I think that RTM_NEWSTATS and RTM_DELSTATS aren't good names, since user doesn't add/del statistics but only query.
> Maybe just stay with RTM_GETSTATS and the message back to user will be RTM_GETSTATS as well?

yeah, i defined all of these because rtnetlink_rcv_msg seems to expect all three to be
there when it tries to check if it is a get msg. But, i could sure not declare this
but make rtnetlink_rcv_msg happy by keeping the GET msg at the right offset.

The RTM_NEWSTATS i thought i should leave it in there because the original thought from
jamal also had periodic stats notification to user-space...which should be RTM_NEWSTATS.
 But, then again that can be added  when we implement that function.


>
>> +	RTM_DELSTATS = 93,
>> +#define RTM_DELSTATS RTM_DELSTATS
> This is not in used
>
>
same response as above. will drop some of them in v2.

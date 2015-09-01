From: ahmed amamou <ahmed@gandi.net>
Subject: Re: [PATCH RFC v2 09/21] net: rbridge: add elected dtroot
Date: Tue, 01 Sep 2015 18:26:12 +0000
Message-ID: <F5DDB952-042C-490A-94B8-051E1797E787@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net> <1441122196-11662-10-git-send-email-ahmed@gandi.net> <55E5EBF5.4070100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: William Dauchy <william@gandi.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:53195 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753303AbbIAS0S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:26:18 -0400
In-Reply-To: <55E5EBF5.4070100@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On September 1, 2015 8:18:29 PM GMT+02:00, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>Hello.
>
>On 09/01/2015 06:43 PM, Ahmed Amamou wrote:
>
>> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
>> ---
>>   net/bridge/rbr.c           | 14 ++++++++++++++
>>   net/bridge/rbr_private.h   |  2 ++
>>   net/bridge/rbr_rtnetlink.c |  6 ++++++
>>   3 files changed, 22 insertions(+)
>>
>> diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
>> index c554743..31e72ef 100644
>> --- a/net/bridge/rbr.c
>> +++ b/net/bridge/rbr.c
>> @@ -69,3 +69,17 @@ void br_trill_set_enabled(struct net_bridge *br,
>unsigned long val)
>>   			br_trill_stop(br);
>>   	}
>>   }
>> +
>> +int set_treeroot(struct rbr *rbr, uint16_t treeroot)
>> +{
>> +	if (unlikely(!VALID_NICK(treeroot))) {
>> +		pr_warn_ratelimited
>> +			("rbr_set_treeroot: given tree root not valid\n");
>> +		goto set_tree_root_fail;
>
>    This seems a bit stupid. Why not *return* directly?

Indeed, we will fix it.
>
>> +	}
>> +	if (rbr->treeroot != treeroot)
>> +		rbr->treeroot = treeroot;
>> +	return 0;
>> + set_tree_root_fail:
>> +	return -ENOENT;
>> +}
>[...]
>
>MBR, Sergei

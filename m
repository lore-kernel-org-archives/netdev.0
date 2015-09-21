From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Mon, 21 Sep 2015 15:28:53 -0600
Message-ID: <56007695.3070003@cumulusnetworks.com>
References: <1442859588-14831-1-git-send-email-dsa@cumulusnetworks.com>
 <20150921141929.681ebf69@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:32967 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbbIUV2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 17:28:47 -0400
Received: by iofh134 with SMTP id h134so133767139iof.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 14:28:47 -0700 (PDT)
In-Reply-To: <20150921141929.681ebf69@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/15 3:19 PM, Stephen Hemminger wrote:
>> @@ -1638,6 +1638,8 @@ static int iproute_get(int argc, char **argv)
>>   	if (req.r.rtm_family == AF_UNSPEC)
>>   		req.r.rtm_family = AF_INET;
>>
>> +	req.r.rtm_flags |= RTM_F_LOOKUP_TABLE;
>> +
>>   	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
>>   		exit(2);
>>
>
> How will this work (or not) on older kernels?
>

It works just fine. First test used the wrong VM and was puzzled to not 
see the table id in the output. Then I realized the older kernel did not 
recognize the RTM_F_LOOKUP_TABLE; silently ignores the flag. With a 
kernel that does recognize it I get the table id in the output when it 
is not main.

David

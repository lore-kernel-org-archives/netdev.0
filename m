From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH iproute2] vxlan: Add support for modifying vxlan device
 attributes
Date: Thu, 4 May 2017 17:26:23 -0700
Message-ID: <c5c7969d-9808-13a9-316b-afe590997127@oracle.com>
References: <1493934394-26317-1-git-send-email-girish.moodalbail@oracle.com>
 <20170504170743.3b411f21@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38813 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdEEA03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 20:26:29 -0400
In-Reply-To: <20170504170743.3b411f21@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 5:07 PM, Stephen Hemminger wrote:
> On Thu,  4 May 2017 14:46:34 -0700
> Girish Moodalbail <girish.moodalbail@oracle.com> wrote:
>
>> Ability to change vxlan device attributes was added to kernel through
>> commit 8bcdc4f3a20b ("vxlan: add changelink support"), however one
>> cannot do the same through ip(8) command.  Changing the allowed vxlan
>> device attributes using 'ip link set dev <vxlan_name> type vxlan
>> <allowed_attributes>' currently fails with 'operation not supported'
>> error.  This failure is due to the incorrect rtnetlink message
>> construction for the 'ip link set' operation.
>>
>> The vxlan_parse_opt() callback function is called for parsing options
>> for both 'ip link add' and 'ip link set'. For the 'add' case, we pass
>> down default values for those attributes that were not provided as CLI
>> options. However, for the 'set' case we should be only passing down the
>> explicitly provided attributes and not any other (default) attributes.
>>
>> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
>> ---
>
> All these foo_set variables are ugly. This looks almost like machine
> generated code. It doesn't read well.

I thought about it, however I wasn't sure if refactoring that whole routine will 
be well received so I decided to follow the current model that already existed 
in iplink_vxlan.c. I will re-submit a patch cleaning up that whole routine.

thanks,
~Girish

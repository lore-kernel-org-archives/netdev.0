From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: cleanup bond_opts array
Date: Mon, 12 Jan 2015 12:05:30 +0100
Message-ID: <54B3AA7A.2010606@redhat.com>
References: <1420828268-10360-1-git-send-email-jtoppins@cumulusnetworks.com> <20150109184821.GC56806@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138AbbALLFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 06:05:34 -0500
In-Reply-To: <20150109184821.GC56806@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/15 19:48, Andy Gospodarek wrote:
> On Fri, Jan 09, 2015 at 01:31:08PM -0500, Jonathan Toppins wrote:
>> Remove the empty array element initializer and size the array with
>> BOND_OPT_LAST so the compiler will complain if more elements are in
>> there than should be.
>>
>> An interesting unwanted side effect of this initializer is that if one
>> inserts new options into the middle of the array then this initializer
>> will zero out the option that equals BOND_OPT_TLB_DYNAMIC_LB+1.
>>
>> Example:
>> Extend the OPTS enum:
>> enum {
>>    ...
>>    BOND_OPT_TLB_DYNAMIC_LB,
>>    BOND_OPT_LACP_NEW1,
>>    BOND_OPT_LAST
>> };
>>
>> Now insert into bond_opts array:
>> static const struct bond_option bond_opts[] = {
>>       ...
>>       [BOND_OPT_LACP_RATE] = { .... unchanged stuff .... },
>>       [BOND_OPT_LACP_NEW1] = { ... new stuff ... },
>>       ...
>>       [BOND_OPT_TLB_DYNAMIC_LB] = { .... unchanged stuff ....},
>>       { } // MARK A
>> };
>>
>> Since BOND_OPT_LACP_NEW1 = BOND_OPT_TLB_DYNAMIC_LB+1, the last
>> initializer (MARK A) will overwrite the contents of BOND_OPT_LACP_NEW1
>> and can be easily viewed with the crash utility.
>>
>> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
>> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> I do not recall if there was a specific reason that Nik added this, so
> presuming there was not....
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> 
Indeed, it's an oversight on my part from a previous version of the opts
patch-set which used a different end-of-array indicator :-)


Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [RFC net-next 0/3] bonding: new option API
Date: Sun, 12 Jan 2014 13:09:05 +0100
Message-ID: <52D285E1.9020209@redhat.com>
References: <1389359495-9700-1-git-send-email-nikolay@redhat.com> <AAA51DDF-74AF-4A70-8072-62F2593F8619@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaALMJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 07:09:12 -0500
In-Reply-To: <AAA51DDF-74AF-4A70-8072-62F2593F8619@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2014 09:32 PM, Scott Feldman wrote:
> 
> On Jan 10, 2014, at 5:11 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> Hi,
>> This patchset aims to introduce a new option API that can be easily
>> extended if necessary and which attempts to remove some common problems
>> and code. In the beginning there was support for inter-option dependencies,
>> but that turned out to be unnecessary as the only 2 options that _enforce_
>> another option to be set prior to setting are up/down delay and they can be
>> easily re-worked to not require miimon to be set, so we can spare ourselves
>> 100+ lines of checks, dealing with complex dependency errors and such.
>> In case this becomes necessary I've kept the old version of this patch-set
>> which has it, and can easily re-work it at any time.
>> There're still a lot of things to fix/clean but I've done some limited testing
>> with the options that are converted and it seems to work.
>> The main exported functions (as can be seen) are:
>> __bond_opt_set() - to be used when a string is passed which needs to be
>>                   converted in the case of BOND_OPTVAL_INTEGER. (sysfs)
>> __bond_opt_intset() - to be used when a value is passed to
>>                      BOND_OPTVAL_INTEGER (netlink), this function can't
>>                      be used for BOND_OPTVAL_STRING options
>> These two can be used from inside other options to stop them (e.g., arp_interval
>> stopping miimon and vice versa).
>> I've also added bond_opt_tryset_rtnl() mostly for sysfs use.
>> See the description of patch 01 and the comments inside for more information.
>>
>> Value tables of converted options are no longer exported, and can be accessed
>> through the API (bond_opt_get_val() & bond_opt_get_flags).
>> Another good side-effect is that the error codes are standard for all options
>> for the common errors at least.
> 
> Nice!
> 
>> When/if this patchset is posted for inclusion, I'll have all options converted.
>> I actually had them before but while on vacation during December a lot of code
>> went in changing the bonding options and have to re-work most of the patches.
> 
> Oops, sorry about that ;)
> 
>> Some of the future plans for this are:
>> Verbose outputting of dependencies (done, just have to polish it)
>> Automatic sysfs generation from the bond_opts[].
> 
> I had a patch in my queue to do something similar, but yours is so much nicer.  
> 
> For sysfs nodes, there is a file permission. I wonder if bond_opts should have a sense of RO, RW, or WO?  Then automatic sysfs generation is even easier.  Hmmm, actually I think the answer is no.  Nevermind.
> 
>> Use of the API in bond_check_params() and thus cleaning it up
>> Structure for accessor fn parameter passing so we can implement get/set
>> in a more general manner
>>
>> Sending it with 2 options converted which illustrate the use of different
>> features of the API. I've tested them via sysfs.
>>
>> Any thoughts, comments and suggestions are very welcome.
> 
> Nice job Nik, well done.
> 
> -scott
> 
Hi Scott,
Thank you for the review, I'll take care of the comments for the first version.
I saw your first comment about generalizing this to more than just the
bonding, I'll look into that because I know I'm reinventing the wheel here
as there are already network drivers which have similar APIs, but such
project would have much larger set of requirements (e.g. a much better and
more descriptive inter-dependency checks, custom errors, custom
permissions, more opaque objects etc.). Maybe we can leave it as the next
step, I have to give it some more thought :-)

Cheers,
 Nik

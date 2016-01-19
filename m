From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] net: Add l3mdev cgroup
Date: Tue, 19 Jan 2016 09:06:02 -0700
Message-ID: <569E5EEA.901@cumulusnetworks.com>
References: <1451925136-13327-1-git-send-email-dsa@cumulusnetworks.com>
 <20160104175836.GA11668@mtj.duckdns.org>
 <568ABFC3.3010803@cumulusnetworks.com>
 <20160104185936.GA3807@mtj.duckdns.org>
 <568AC534.1070308@cumulusnetworks.com>
 <20160104192301.GC3807@mtj.duckdns.org>
 <568ACF13.3030007@cumulusnetworks.com>
 <20160104200518.GD3807@mtj.duckdns.org> <20160119080321.0a8fe1c8@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>,
	Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36650 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756874AbcASQGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 11:06:05 -0500
Received: by mail-oi0-f54.google.com with SMTP id o124so186908325oia.3
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 08:06:05 -0800 (PST)
In-Reply-To: <20160119080321.0a8fe1c8@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/16 9:03 AM, Stephen Hemminger wrote:
> On Mon, 4 Jan 2016 15:05:18 -0500
> Tejun Heo <tj@kernel.org> wrote:
>
>> Hello,
>>
>> On Mon, Jan 04, 2016 at 12:59:15PM -0700, David Ahern wrote:
>>> cgroups have very nice properties that I want to leverage such as
>>> parent-child inheritance and easy tracking which subsystem instance a task
>>> belongs. This provides a great kernel foundation for building easy to use
>>> management tools.
>>>
>>> The documentation for cgroups does not restrict a controller to physical
>>> resources but rather "it may be anything that wants to act on a group of
>>> processes." That is exactly what I am doing here - I have a network config
>>> that is applied to a group of processes similar to net_cls and net_prio (but
>>> as I stated before those are orthogonal, independent settings from the L3
>>> domain).
>>
>> Please read the new version of cgroup documentation.
>>
>>    https://git.kernel.org/cgit/linux/kernel/git/tj/cgroup.git/tree/Documentation/cgroup.txt?h=for-4.5
>>
>> cgroup has experienced a lot of problems doing its main job -
>> hierarchical resource control - from trying to support random things
>> which want to group threads.  As shown with xt_cgroup, such
>> identifying usages can be implemented in a way where the subsystem
>> matches the membership rather than cgroup taking in configurations
>> which belong to the subsystem, so please investigate that direction.
>>
>> Thanks.
>>
>
> Policy like this belongs in userspace not kernel.
>


This is the infrastructure that allows userspace to implement a policy - 
the policy being binding tasks and their children to an L3 domain.

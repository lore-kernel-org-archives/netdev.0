From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Thu, 23 Feb 2017 22:12:57 -0500 (EST)
Message-ID: <20170223.221257.795227595252531962.davem@redhat.com>
References: <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
        <20170223163035.0a49f04d@xeon-e3>
        <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43086 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751303AbdBXDNR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 22:13:17 -0500
In-Reply-To: <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 23 Feb 2017 18:07:07 -0700

> On 2/23/17 5:30 PM, Stephen Hemminger wrote:
>> On Thu, 23 Feb 2017 16:39:52 -0700
>> David Ahern <dsa@cumulusnetworks.com> wrote:
>> 
>>> On 2/23/17 12:50 PM, Stephen Hemminger wrote:
>>>> Some use cases create Linux networking devices which are not intended for use
>>>> by normal networking. This is an enhancement to ip command to hide network
>>>> devices starting with period (like files in normal directory).  Interfaces whose
>>>> name start with "." are not shown by default, and the -a (or -all) flag must
>>>> be used to show these devices.  
>>>
>>> Agree that some devices need to be hidden by default -- not just from
>>> users but also other processes.
>>>
>>> This solution is very narrow, only affecting iproute2 users. Any other
>>> programs that use netlink or /proc files will continue to see those devices.
>> 
>> I want solution that works broadly. And this works for sysfs already.
> 
> for 'ls' maybe, but not general walking of /sys. It does not hide
> devices from snmpd, from ifconfig, etc., etc.

I agree, that this is a pretty poor assumption.

And relying upon tool specific behavior to provide this facility
is even more special purpose.

This really need to be a fundamental facility, so that it transparently
works for NetworkManager, router daemons, everything.  Not just iproute2
and "ls".

From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: hide devices starting with period by default
Date: Thu, 23 Feb 2017 17:31:14 -0800
Message-ID: <20170223173114.621cb747@xeon-e3>
References: <20170223195028.16388-1-stephen@networkplumber.org>
        <027775d1-ef98-deda-1f8d-bb058d1e4c2f@cumulusnetworks.com>
        <20170223163035.0a49f04d@xeon-e3>
        <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34273 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbdBXBhm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 20:37:42 -0500
Received: by mail-pg0-f44.google.com with SMTP id 1so3942173pgi.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 17:37:42 -0800 (PST)
In-Reply-To: <13cec1c2-88f4-e61d-02ee-dc01ccee7281@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Feb 2017 18:07:07 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 2/23/17 5:30 PM, Stephen Hemminger wrote:
> > On Thu, 23 Feb 2017 16:39:52 -0700
> > David Ahern <dsa@cumulusnetworks.com> wrote:
> >   
> >> On 2/23/17 12:50 PM, Stephen Hemminger wrote:  
> >>> Some use cases create Linux networking devices which are not intended for use
> >>> by normal networking. This is an enhancement to ip command to hide network
> >>> devices starting with period (like files in normal directory).  Interfaces whose
> >>> name start with "." are not shown by default, and the -a (or -all) flag must
> >>> be used to show these devices.    
> >>
> >> Agree that some devices need to be hidden by default -- not just from
> >> users but also other processes.
> >>
> >> This solution is very narrow, only affecting iproute2 users. Any other
> >> programs that use netlink or /proc files will continue to see those devices.  
> > 
> > I want solution that works broadly. And this works for sysfs already.  
> 
> for 'ls' maybe, but not general walking of /sys. It does not hide
> devices from snmpd, from ifconfig, etc., etc.
> 
> 
> >> I started a patch a year ago that allows devices to marked as invisible
> >> (attribute can be toggled at any time). Invisible devices do not show up
> >> in netlink dumps, proc files or notifications. Netlink dumps can request
> >> invisible devices to be included in a link dump. While it is more
> >> intrusive, it is also more complete covering all of the paths in which
> >> the device is shows up.
> >>
> >> Also, changing the default behavior for iproute2 could break existing
> >> users that have such device names.  
> > 
> > I am less worried about this. The only people using . in name already
> > are probably Brocade, and they have similar thing in CLI to hide these
> > devices.  
> 
> 
> seems like a big assumption.

Need a solution now, not something that requires kernel and command changes.

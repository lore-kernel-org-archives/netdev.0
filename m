From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH v2 net-next 0/3] Allow bridge to function in
 non-promisc mode
Date: Fri, 8 Mar 2013 13:43:14 -0800
Message-ID: <20130308134314.318d31c6@nehalam.linuxnetplumber.net>
References: <1362691728-13289-1-git-send-email-vyasevic@redhat.com>
	<20130307214304.25e7784e@nehalam.linuxnetplumber.net>
	<513A0109.4040607@redhat.com>
	<513A56E9.2090708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:35330 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab3CHVnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 16:43:21 -0500
Received: by mail-pb0-f50.google.com with SMTP id up1so1607574pbc.23
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 13:43:21 -0800 (PST)
In-Reply-To: <513A56E9.2090708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Mar 2013 16:23:53 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 03/08/2013 10:17 AM, Vlad Yasevich wrote:
> > On 03/08/2013 12:43 AM, Stephen Hemminger wrote:
> >> On Thu,  7 Mar 2013 16:28:45 -0500
> >> Vlad Yasevich <vyasevic@redhat.com> wrote:
> >>
> >>> The series adds an ability to configure the bridge into a
> >>> non-primiscuous
> >>> mode.   Instead, it provides the ability to identitfy some set of bridge
> >>> ports as uplinks and allows for MAC addresses to be programmed onto
> >>> those ports.  In case the port hardware does not support mac filter,
> >>> that port will be placed in promiscuous mode.
> >>>
> >>> Default bridge operation continues to remain as "promiscuous".  The new
> >>> functionality has to be enabled via sysfs (similar to other bridge
> >>> extensions).
> >>>
> >>> The uplink mode is implemented as a flag on a bridge port.  The api to
> >>> change that flag follows the existing api to enable/disable other
> >>> existing
> >>> flags.
> >>>
> >>> All comments are welcome.
> >>>
> >>
> >> Can we make this a one step process and less visible to the user.
> >> If user defines an uplink device, and the uplink device is capable of
> >> filtering
> >> (and what ever other pre-conditions people can think of), then the
> >> bridge will
> >> transparently switch to uplink/non-promisc mode.  This can also be
> >> used to trigger
> >> edge only mode in RSTP in the future.
> >>
> >> Less knobs.
> >>
> >
> > Ok.  Let me see what I can do.
> 
> So I started working through this and realized that this complicates the 
> code significantly.
> 
> * I have to re-introduce the uplink-list since now I need to track
> "filter capable" uplinks in addition to non-capable ones.
> * The really nice and simple sysfs interface to set a flag turns into 
> something that duplicates code.
> * The bridge port removal can effect the promiscuity setting of the 
> bridge if the last uplink is removed.
> * We lose the ability to run a promisc edge bridge with uplinks.
> 
> I am really starting wonder if this is any better?  The changes
> are much bigger and more complex while the functional flexibility is
> reduced.  Is it really worth removing a configuration knob?
> 
> I've attached an in-progress patch to demonstrate the above.
> 
> -vlad
> 
> -vlad
> >
> > Thanks
> > -vlad
> >
> 

A two step process is fine (uplink and promisc as seperate step),
as long as invalid combinations are prevented. More options may lead to
more combinations that are invalid.

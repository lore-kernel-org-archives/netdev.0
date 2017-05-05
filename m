From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: Add support for modifying vxlan device
 attributes
Date: Fri, 5 May 2017 09:47:03 -0700
Message-ID: <20170505094703.2b2eded0@xeon-e3>
References: <1493934394-26317-1-git-send-email-girish.moodalbail@oracle.com>
        <20170504170743.3b411f21@xeon-e3>
        <c5c7969d-9808-13a9-316b-afe590997127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36005 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdEEQrF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:47:05 -0400
Received: by mail-pf0-f171.google.com with SMTP id q66so5153132pfi.3
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 09:47:05 -0700 (PDT)
In-Reply-To: <c5c7969d-9808-13a9-316b-afe590997127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 May 2017 17:26:23 -0700
Girish Moodalbail <girish.moodalbail@oracle.com> wrote:

> On 5/4/17 5:07 PM, Stephen Hemminger wrote:
> > On Thu,  4 May 2017 14:46:34 -0700
> > Girish Moodalbail <girish.moodalbail@oracle.com> wrote:
> >  
> >> Ability to change vxlan device attributes was added to kernel through
> >> commit 8bcdc4f3a20b ("vxlan: add changelink support"), however one
> >> cannot do the same through ip(8) command.  Changing the allowed vxlan
> >> device attributes using 'ip link set dev <vxlan_name> type vxlan
> >> <allowed_attributes>' currently fails with 'operation not supported'
> >> error.  This failure is due to the incorrect rtnetlink message
> >> construction for the 'ip link set' operation.
> >>
> >> The vxlan_parse_opt() callback function is called for parsing options
> >> for both 'ip link add' and 'ip link set'. For the 'add' case, we pass
> >> down default values for those attributes that were not provided as CLI
> >> options. However, for the 'set' case we should be only passing down the
> >> explicitly provided attributes and not any other (default) attributes.
> >>
> >> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> >> ---  
> >
> > All these foo_set variables are ugly. This looks almost like machine
> > generated code. It doesn't read well.  
> 
> I thought about it, however I wasn't sure if refactoring that whole routine will 
> be well received so I decided to follow the current model that already existed 
> in iplink_vxlan.c. I will re-submit a patch cleaning up that whole routine.
> 
> thanks,
> ~Girish
> 

Thanks. This is one of those cases where something new gets added and additional
refactoring (that was overdue) is needed.

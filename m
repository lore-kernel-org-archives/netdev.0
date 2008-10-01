From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 17:11:57 +0400
Message-ID: <1222866717.23573.58.camel@iris.sw.ru>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	 <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru>
	 <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru>
	 <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>
	 <48E36DA0.9080400@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2409 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477AbYJANNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 09:13:48 -0400
In-Reply-To: <48E36DA0.9080400@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-01 at 14:31 +0200, Daniel Lezcano wrote:
> Pavel Emelyanov wrote:
> >> So there are 2 cases:
> >>   * full isolation : restriction on VPS
> >>   * partial isolation : no restriction but *perhaps* problem when migrating
> >>
> >> Looks like we need an option per namespace to reduce the isolation for 
> >> af_unix sockets :)
> >>   - on (default): current behaviour => full isolation
> >>   - off : partial isolation
> > 
> > You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
> 
> Yes.

I do not see much sense with sysctl as:
- check (cross-connected sockets) is required as we can start namespace
  with already opened socket
- this kind of sharing is not implicit but explicit as normal isolated
  containers _must_ have separate filesystems. In this case this
  sharing requires explicit host administrator action to link socket
  between containers


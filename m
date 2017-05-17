From: Bastian Bittorf <bb@npl.de>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Wed, 17 May 2017 20:34:31 +0200
Message-ID: <20170517183431.GG2849@medion.lan>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
 <20170517100844.GC2849@medion.lan>
 <1495027835.2442.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: Ben Greear <greearb@candelatech.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:55909 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752375AbdEQSeV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:34:21 -0400
Content-Disposition: inline
In-Reply-To: <1495027835.2442.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Johannes Berg <johannes@sipsolutions.net> [17.05.2017 20:18]:
> On Wed, 2017-05-17 at 12:08 +0200, Bastian Bittorf wrote:
> > * Ben Greear <greearb@candelatech.com> [17.05.2017 11:51]:

[...]

> > > kernels, but when testing on 4.9 overnight, I notice that 'iw
> > > events' is not showing any input.  'strace' shows
> > > that it is waiting on recvmsg.  If I start a second 'iw events'
> > > then it will get
> > > wifi events as expected.
> > 
> > me too, also seen on 4.4 - i'am happy for debug ideas.
> 
> I've never seen this.
> 
> Does it happen when it's very long-running? Or when there are lots of
> events?

only a couple of hours. hard to say which is the culprit. here
i run it like:

#!/bin/sh
iw event | while read -r LINE; do
 case "$LINE" in
  *': new station '*) ... ;;
  *': del station '*) ... ;;
 esac
done


The script marks new stations with "touch /tmp/$mac"
and removes this file during 'del station'.

What is interesting: i can recognize, that sometimes and
somehow i have stations in 'iw dev wlanX station dump' which
the script has not seen. When debugging this, the script
does not get any new events. A new started 'iw event' can
see further events without problems.

Hard to say where the error happens. I'am on busybox here.

bye, Bastian

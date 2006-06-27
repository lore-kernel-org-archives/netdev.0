From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Tue, 27 Jun 2006 20:49:09 +0400
Message-ID: <20060627164909.GA20230@ms2.inr.ac.ru>
References: <20060626134711.A28729@castle.nmd.msu.ru> <449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru> <44A00215.2040608@fr.ibm.com> <20060627131136.B13959@castle.nmd.msu.ru> <44A0FBAC.7020107@fr.ibm.com> <20060627133849.E13959@castle.nmd.msu.ru> <44A1149E.6060802@fr.ibm.com> <m1sllqn7cb.fsf@ebiederm.dsl.xmission.com> <20060627160241.GB28984@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161202AbWF0Que@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrey Savochkin <saw@swsoft.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	sam@vilain.net, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>
Content-Disposition: inline
In-Reply-To: <20060627160241.GB28984@MAIL.13thfloor.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 06:02:42PM +0200, Herbert Poetzl wrote:

>  - loopback traffic inside a guest is insignificantly
>    slower than on a normal system
> 
>  - loopback traffic on the host is insignificantly
>    slower than on a normal system
> 
>  - inter guest traffic is faster than on-wire traffic,
>    and should be withing a small tolerance of the
>    loopback case (as it really isn't different)

I do not follow what are you people arguing about?

Intra-guest, guest-guest and host-guest paths have _no_ differences
from host-host loopback. Only the device is different:
* virtual loopback for intra-guest
* virtual interface for guest-guest and host-guest

But the work is exactly the same, only the place where packets
looped back is different. How could this be issue to break a lance over? :-)

Alexey


PS. The only thing, which I can imagine is "optimized" out ip_route_input()
in the case of loopback. But this optimization was an obvious design mistake
(mine, sorry) and apparently will die together with removal of current
deficiences of routing cache. Actually, it is one of deficiences.

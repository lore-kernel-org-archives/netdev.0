From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] libteam: fix function names to include 'bond'
Date: Thu, 10 Nov 2011 07:41:55 +0100
Message-ID: <20111110064154.GA2058@minipsycho>
References: <1319660867-945-1-git-send-email-jpirko@redhat.com>
 <1320862846-6000-1-git-send-email-fbl@redhat.com>
 <20111109220423.GA2112@minipsycho>
 <20111109212308.4f89739e@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1KJGm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 01:42:26 -0500
Content-Disposition: inline
In-Reply-To: <20111109212308.4f89739e@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 10, 2011 at 12:23:08AM CET, fbl@redhat.com wrote:
>On Wed, 9 Nov 2011 23:04:25 +0100
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> 
>> Hi Flavio.
>> 
>> Thomas included these 2 functions in latest libnl upstream. Bond
>> versions wouldn't work because of "bond" type check.
>> 
>
>Yeah, my first option would be using git repo, but the one
>mentioned in the page seems to be off and I am not finding
>another one.  Do you have the repo url handy?

git://git.infradead.org/users/tgr/libnl.git

>
>Anyway, I've tried here with my patch applied and it didn't work.
>Every packet transmitted increased TX dropped in ifconfig team0
>output. The tcpdump attached to the slave doesn't show anything,
>the packets appear only when attached to team0.
>
>When I ping the team0 host from another host, both slave and
>team0 RX dropped increases at the same rate. tcpdump attached
>to the slave shows the packet coming.
>
>Well, maybe this is an effect of having used the wrong libnl
>version, though the team_monitor seems to be working just fine.
>(patch applied on top of net-next of today, commit e56c57d,
> followed the exact same steps as in HOWTO.BASICS)

Oh. I changed activebackup mode behaviour in V4 or V5 of kernel patch.
Now it's needed to adjust mac address of ports by hand. I'll refresh
HOWTO.BASICS shortly. 

>
>I am planning to upgrade the system to the new fedora and
>try again after that.  If I have time, I will follow up with
>fresh results.
>
>thanks,
>fbl
>
>> Jirka
>> 
>> Wed, Nov 09, 2011 at 07:20:46PM CET, fbl@redhat.com wrote:
>> >Signed-off-by: Flavio Leitner <fbl@redhat.com>
>> >---
>> >
>> > I found those while trying to test V6 patch using latest
>> > libteam (commit 5e9790816606a6dd4e7f6f32c0bb0c45e5d13b31)
>> > and libnl-3.2.2 (last stable).
>> > thanks,
>> > fbl
>> >
>> > lib/libteam.c |    4 ++--
>> > 1 files changed, 2 insertions(+), 2 deletions(-)
>> >
>> >diff --git a/lib/libteam.c b/lib/libteam.c
>> >index feb13b6..e7ae6b0 100644
>> >--- a/lib/libteam.c
>> >+++ b/lib/libteam.c
>> >@@ -1331,7 +1331,7 @@ int team_port_add(struct team_handle *th,
>> >uint32_t port_ifindex)
>> > {
>> > 	int err;
>> > 
>> >-	err = rtnl_link_enslave_ifindex(th->nl_cli.sock,
>> >th->ifindex,
>> >+	err = rtnl_link_bond_enslave_ifindex(th->nl_cli.sock,
>> >th->ifindex,
>> > 					port_ifindex);
>> > 	return -nl2syserr(err);
>> > }
>> >@@ -1350,6 +1350,6 @@ int team_port_remove(struct team_handle *th,
>> >uint32_t port_ifindex)
>> > {
>> > 	int err;
>> > 
>> >-	err = rtnl_link_release_ifindex(th->nl_cli.sock,
>> >port_ifindex);
>> >+	err = rtnl_link_bond_release_ifindex(th->nl_cli.sock,
>> >port_ifindex);
>> > 	return -nl2syserr(err);
>> > }
>> >-- 
>> >1.7.6
>> >
>

From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 net-next 2/4] net: dev: add batching to net_device
 notifiers
Date: Sun, 7 Feb 2016 12:09:22 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602071111030.1526@ja.home.ssi.bg>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com> <1454628956-4803-3-git-send-email-noureddine@arista.com> <alpine.LFD.2.11.1602062023180.1718@ja.home.ssi.bg> <CAO7SqHAX7e6sXkcEmd-hAn=Sg4AdNCRS1iFN7_F=aDnidnZOvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59974 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753551AbcBGKJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 05:09:59 -0500
In-Reply-To: <CAO7SqHAX7e6sXkcEmd-hAn=Sg4AdNCRS1iFN7_F=aDnidnZOvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 6 Feb 2016, Salam Noureddine wrote:

> On Sat, Feb 6, 2016 at 10:58 AM, Julian Anastasov <ja@ssi.bg> wrote:

> >> +     /* call batch notifiers which act on net namespaces */
> >> +     list_for_each_entry(dev, head, unreg_list) {
> >> +             net_add_event_list(&net_head, dev_net(dev));
> >
> >         Looks like we can move the above net_add_event_list with
> > the comment into the previous loop after NETDEV_UNREGISTER,
> > we will save some cycles.
> 
> I didn't move it into the previous loop because the NETDEV_UNREGISTER
> notifier can
> end up calling rollback_registered_many (for example the vlan driver
> unregistering
> all vlans on top of a device) in which case we would be using the
> event_list in the net
> namespace.

	ok. May be another safe option is to call it just before
NETDEV_UNREGISTER, so that if rollback_registered_many is called
recursively we will have single NETDEV_UNREGISTER_BATCH call.
Same should work for NETDEV_DOWN_BATCH in dev_close_many. But
these are small optimizations, so it is up to you to decide.

Regards

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: wireless vs. network namespaces
Date: Fri, 14 Sep 2007 09:31:09 -0600
Message-ID: <m1bqc52ria.fsf@ebiederm.dsl.xmission.com>
References: <1189763513.3974.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1189763513.3974.26.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (Johannes Berg's message
	of "Fri, 14 Sep 2007 11:51:53 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> Now that the network namespace work is in net-2.6.24, I'm wondering how
> wireless will be handling this. Is there any benefit at all to a
> wireless device supporting network namespaces?

Good question.  Network namespaces are designed as a general tool
so if we can support network namespaces in the wireless stack without
killing ourselves there should be value in it.

> Should we, for now, set the new NETIF_F_NETNS_LOCAL flag for all
> mac80211 devices?
>
> If we do want to support moving, then we'll have to make cfg80211
> (preferably, though mac80211 might be easier at first) migrate *all*
> virtual interfaces associated with the same wiphy because otherwise
> we'll get into trouble when moving one virtual interface and then
> somebody in the other namespace changes its operating channel.

Ok.  This appears at least to be an atomicity issue and possibly more.

I don't currently understand the way the wireless interfaces interact
well enough to make a judgement call.

There are two basic usage models I can currently think of.
1) Super chroot.  Where a group of processes has distinct mount,
   network, uts, ipc, and pid namespaces.  So in this case on the
   inside we will only see processes that only belong to our own
   network namespace.  So in this scenario you get whatever the person
   who sets up the environment gives you.

   If one of the network devices only allows access to a subset of
   the wireless networking  (say just sending packets but not
   controlling the radio aspects) I can see and advantage in only
   having that device in the restricted network namespace.

2) Advanced routing.  Where someone is doing some weird thing like 
   testing sending packets and receiving them on the same machine.

Currently creation of a network namespace requires CAP_SYS_ADMIN
and for device movement we only require CAP_NET_ADMIN.  So these are
all privileged operations.  So the scenario you are concerned about
may just be a "don't do that then".

If this doesn't give you enough information to make the call can
you describe for me how the separation of wireless network interfaces
work?

Eric

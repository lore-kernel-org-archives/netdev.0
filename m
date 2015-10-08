From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: report features supported by the
 kernel datapath
Date: Thu, 8 Oct 2015 15:40:57 -0700
Message-ID: <CAEP_g=-pgG6yhGsbvbdrJdAK3VXX1a+8c-wRkHuRte0=2Byg2w@mail.gmail.com>
References: <f035dbc85f4fb7e8c8691801849a9db286154bde.1444312374.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34438 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933464AbbJHWlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 18:41:18 -0400
Received: by lbbwt4 with SMTP id wt4so62831050lbb.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 15:41:17 -0700 (PDT)
In-Reply-To: <f035dbc85f4fb7e8c8691801849a9db286154bde.1444312374.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 6:53 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Allow the user space to query what features are supported by the openvswitch
> module. This will be used to allow or disallow certain configurations and/or
> switch between newer and older APIs depending on what the kernel supports.
>
> Two features are reported as supported by this patch: lwtunnel and IPv6
> tunneling support. Theoretically, we could merge these two, as any of them
> implies the other with this patch applied, but it's better to keep them
> separate: kernel 4.3 supports lwtunnels but not IPv6 for ovs, and the
> separation of the two flags allows us to backport a version of this patch
> to 4.3 should the need arise.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

I have similar concerns as were expressed in the other thread. The
features listed here aren't OVS components and I don't think that it
makes sense for OVS to try to cover everything that is related - the
goal that we've been working towards is to have OVS be less monolithic
and more integrated. So to the extent that it is necessary to have
capabilities be exposed (and I would like to avoid this where
possible), it should be in the individual component, not in OVS.

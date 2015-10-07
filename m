From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Wed, 7 Oct 2015 11:34:01 +0200
Message-ID: <20151007093401.GA28717@pox.localdomain>
References: <CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
 <20151006175634.200d69a0@griffin>
 <CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
 <20151006204558.5f2f56fc@griffin>
 <CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
 <20151006210358.65750aeb@griffin>
 <CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
 <20151006213245.74810d81@griffin>
 <CALnjE+p2KQqZsgkHYsWrJfKUCev85eGH6TWdrQHTA-9KxO9tjQ@mail.gmail.com>
 <20151007100955.3f13120e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>, netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33888 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbbJGKcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 06:32:25 -0400
Received: by wicfx3 with SMTP id fx3so205555139wic.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 03:32:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151007100955.3f13120e@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/15 at 10:09am, Jiri Benc wrote:
> The big difference to the other features is this cannot be detected
> until half way through the setup.
> 
> What I'm proposing instead is to introduce a way to clearly and
> unambiguously detect whether lwtunnels are supported or not. We'll need
> this anyway: kernel 4.3 won't really support IPv6 tunneling with ovs,
> yet there's currently no way to determine whether it's supported or not
> (and, unlike with lwtunnel detection, there's not even a hacky way).
> Querying the datapath for the supported features is needed
> nevertheless; it's only logical to use it for the lwtunnel vs. old
> vport decision, too.
> 
> I don't understand why you're opposed to this: it's much cleaner and
> there's no problem with lwtunnels not being used with the 4.3 kernel,
> everything should work just fine.

Extending ovs_dp_cmd_fill_info() to dump a new dp->kernel_features
via a new Netlink attribtue which signals these capabilities looks
like a straight forward way to solve this.

OVS just needs to set NLM_F_ECHO when creating the initial datapath.

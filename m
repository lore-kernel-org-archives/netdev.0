From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 2/2] tc: m_tunnel_key: add csum/nocsum option
Date: Thu, 15 Jun 2017 10:21:10 +0200
Message-ID: <20170615102110.7e740c3e@griffin>
References: <cover.1497467840.git.jbenc@redhat.com>
        <20170614213018.364cd85d@griffin>
        <20170614133807.2320f98b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42566 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752075AbdFOIVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 04:21:16 -0400
In-Reply-To: <20170614133807.2320f98b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 13:38:07 -0700, Stephen Hemminger wrote:
> Does this change the default? Before your patches what was the checksum
> setting for the new tunnel.

Yes, it does. See the kernel patches.

I realize it's a user visible change; however, given that the real
reason act_tunnel_key was introduced is offloading of openvswitch and
openvswitch doesn't use it yet and I very much doubt there are other
users, I'm still proposing the change. It makes things aligned between
the non-lwt tunnels, tc and even the current openvswitch (which
includes the csum by default as well). When someone someday starts
using lwtunnels with tc for other uses, this will make it much less
surprising and will prevent user errors. Not mentioning performance
which is in general going to be better with the csum.

Furthermore, the only use case for nocsum is a compatibility with
broken VTEPs from hw vendors. This is not a setup act_tunnel_key is
going to be used in: in such case, you pretty much want the VXLAN
internal control plane, not an external one.

We're also not breaking existing Linux setups, even if there were any.
Even with udp6zerocsumrx, the non-zero csumed packets are still
accepted.

I was notified about the current confusing behavior by Red Hat QA when
they were trying to test the tunnel_key action and couldn't make it
work for IPv6. When those guys needed a help of the kernel developer
and the kernel developer in question had to insert a few printks to
realize what's going on, no regular user would be able to use it ;-)
(Of course, that's "fixable" by documentation.)

 Jiri

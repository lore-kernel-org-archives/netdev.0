From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 20:07:46 -0800
Message-ID: <CALx6S37gHYMJdz3MzfjKwLHsw0Pmg0SxvQ036sg35AjRackARQ@mail.gmail.com>
References: <20160311182949.GG3383@oracle.com>
	<20160311110927.5c559421@xeon-e3>
	<20160312024341.GA26486@oracle.com>
	<CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
	<20160312034421.GB26486@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33882 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbcCLEHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 23:07:48 -0500
Received: by mail-lb0-f172.google.com with SMTP id xr8so174350092lbb.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 20:07:47 -0800 (PST)
In-Reply-To: <20160312034421.GB26486@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 7:44 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/11/16 19:21), Tom Herbert wrote:
>> You could consider and alternate model where connection management
>> (connect, listen, etc.) is performed in a userspace daemon and the
>> attached to the kernel (pretty much like KCM does). This moves
>
> You have to remember that, like it or not, RDS has some IB legacy
> compat requirements that cannot be shed easily.  The above suggestion
> suddenly requiring an extra daemon per node in a cluster
> involving 100's of nodes with very complex DB setup procedures and
> rigid HA requirements (nodes in the cluster try to reconnect
> on connection failure).  An extra daemon, with its own startup requirements
> and additional latency, would be hard to justify for something
> that can otherwise be done with module_param.
>
You are describing your deployment of RDS, not kernel implementation.
What I see is a very rigid implementation that would make it hard for
many us to ever even consider deploying. The abilities of applications
to tune TCP connections is well understood, very prevalent, and really
fundamental in making TCP based datacenters at large scale. Any way,
it was just an idea... ;-)

> As such, the above suggestion is even non-trivial than the "ugly" code
> I referred to in my previous email.
>
> It is actually far simpler to just tell the cluster-setup scripts to just
> refrain from an ifup of the relevant interfaces till all the config
> is set up.
>
> Besides, the basic problem remains: for an arbitrary kernel module
> that has parameters that need to be customized before module init,
> what are the options today?
>
Maybe add one module parameter that indicates the module should just
load but not start, configure whatever is needed via netlink, and then
send one more netlink command to start operations.

> --Sowmini

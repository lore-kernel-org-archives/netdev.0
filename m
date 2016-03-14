From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Mon, 14 Mar 2016 10:57:17 -0700
Message-ID: <CALx6S37m5s+6h4v1gKiBv2e2p+Ft9Ub4g-YLREWe=A5iuZAseA@mail.gmail.com>
References: <20160311182949.GG3383@oracle.com>
	<20160311110927.5c559421@xeon-e3>
	<20160312024341.GA26486@oracle.com>
	<CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
	<20160312034421.GB26486@oracle.com>
	<CALx6S37gHYMJdz3MzfjKwLHsw0Pmg0SxvQ036sg35AjRackARQ@mail.gmail.com>
	<20160312043952.GC26486@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36566 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719AbcCNR5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:57:18 -0400
Received: by mail-ig0-f182.google.com with SMTP id nk17so45836413igb.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 10:57:18 -0700 (PDT)
In-Reply-To: <20160312043952.GC26486@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 8:39 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/11/16 20:07), Tom Herbert wrote:
>
>> You are describing your deployment of RDS, not kernel implementation.
>> What I see is a very rigid implementation that would make it hard for
>> many us to ever even consider deploying. The abilities of applications
>> to tune TCP connections is well understood, very prevalent, and really
>> fundamental in making TCP based datacenters at large scale.
>
> sorry, historically, OS DDI/DKI's for kernel modules have always
> had some way to set up startup parameters at module load time.  And
> clusters have been around for a while.
>
> So let's just focus on the technical question around module config here,
> which involves more than TCP sockets, btw.
>
>>  Any way, it was just an idea... ;-)
>
> Thank you.
>
> Moving on,
>
>> Maybe add one module parameter that indicates the module should just
>> load but not start, configure whatever is needed via netlink, and then
>> send one more netlink command to start operations.
>
> Even that needs an extra daemon.
>
> Without getting into the vast number of questions that it raises (such
> as every module with startup params now needs a uspace counterpart?
> modprobe-r behavior, namespace behavior? Why netlink for every kernel
> module? etc)..
>
Most modules of any significant complexity are managed via netlink,
and so all of your questions have likely already been answered. Yes,
netlink assumes userspace configuration tools ("ip" configuration many
different networking modules). There are simple interfaces to
create/delete a module's netlink hooks when module is added/removed.
Netlink operates in the context of network namespaces. netlink is
preferred since it is far more extensible and generic for
configuration than sysctl, module params, etc.

Tom

> One module parameter is as much a "distribution management"
> problem as 10 of them, yes? I hope you see that I dont need that module
> param and daemon baggage- I can just use  sysctl to set up all my params,
> including one bit for module_can_start_now to achieve the same thing.
>
> But it is still more than the handful of lines of code in my patch,
> so it would be nice to understand what is the "distribution" issue.
>
> Stepping back, how do we make sysctl fully namespace friendly?
>
> btw setting kernel socket keepalive params via sysctl is not a problem
> to implement at all, if it ever shows up as a requirement for customers.
>
> --Sowmini
>

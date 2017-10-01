From: "Sergey K." <simkergey@gmail.com>
Subject: Re: tc-ipt v0.2: Extension does not know id 1504083504
Date: Sun, 1 Oct 2017 20:25:39 +0600
Message-ID: <CAGv8E+x_4mkFrKaoJgh8dnh6ZyN7oSHRCpT6GQZKFRECOn8EtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org, bugfood-ml@fatooh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:49370 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdJAOZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 10:25:40 -0400
Received: by mail-io0-f172.google.com with SMTP id 21so2999601iof.6
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 07:25:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Funny, I just ran into this too and subscribed here to report it. The
> error occurs during parsing of any options to the jump target; if the
> target has no options, there is no error.
>
> The problem seems to be an outdated version of struct xtables_target in
> include/xtables.h. The version in iptables has an additional member
> "udata" that makes the offsets in the struct different for anything
> following.
>
> A quick fix for this particular problem is to copy include/xtables.h from:
> git://git.netfilter.org/iptables
> ...into include/ in the iproute2 source, then recompile after a 'make
> clean'.
>
> As for a comprehensive fix, I don't know--presumably other headers in
> include/ may be out of date, but I don't want to just blindly send a
> patch unless someone who knows the ramifications says it's ok. This
> seems like it would need maintainer oversight. If there's something I
> can do, though, let me know.
>
>-Corey

Hi Corey.

I did it on your recommendation, replaced xtables.h file from my
version of iptables 1.6.0, and replaced the file netfilter.h.

Now it's works, but new construction doesn't:

# tc filter add dev eth0 parent ffff: u32 match u32 0 0 action xt -j
SET --map-set WORLD_QoS dst
xt: unrecognized option '--map-set'
failed to find target (null)

bad action parsing
parse_action: bad value (6:xt)!
Illegal "action"

my ipset chain:
# ipset -L WORLD_QoS
Name: WORLD_QoS
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 65536 skbinfo
Size in memory: 96
References: 1
Members:

------------------------------------------------

If I will try to execute:

# tc filter add dev eth0 parent ffff: u32 match u32 0 0 action xt -j SET

tc-ipt v0.2: You must specify either `--add-set' or `--del-set' or `--map-set'

it looks like it possible to use this construction.

Is it possible?

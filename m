From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to
 reflect HW offload status
Date: Sun, 12 Feb 2017 11:46:21 +0200
Message-ID: <CAJ3xEMhEMexUT66xi+1JqTijs32a_O_V8AmwG9UdU5MgWsjGpA@mail.gmail.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
 <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com> <20170209172223.405b9e2f@cakuba.netronome.com>
 <CAJ3xEMh_2PdQXb01NmMnvaRyMzxC8VtNnu8XCqvPLQYRwYJPuQ@mail.gmail.com> <20170210094244.6feb9c47@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34606 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdBLJqX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 04:46:23 -0500
Received: by mail-oi0-f67.google.com with SMTP id w144so5187667oiw.1
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 01:46:22 -0800 (PST)
In-Reply-To: <20170210094244.6feb9c47@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 7:42 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Fri, 10 Feb 2017 18:33:13 +0200, Or Gerlitz wrote:
>> On Fri, Feb 10, 2017 at 3:22 AM, Jakub Kicinski <kubakici@wp.pl> wrote:

>> > In cls_bpf we do store information about whether program is offloaded or
>> > not already (see the @offloaded member).  Could we simplify the code
>> > thanks to this?

>> yeah, I felt like I don't fully understand the role of the offloaded
>> member. As I wrote, this patch is compile tested only, I will be happy
>> if you can test it post here a better version, I don't think we need
>> to add/change the flags semantics, see next

> The @offloaded member just tells us whether the program is offloaded.
> We need it because unlike u32 and flower (I think) we have explicit
> ADD and REPLACE.  Other filters just always do REPLACE.  I assume the
> driver keeps track if there is already an associated rule in that case?

In flower you always add new filter through the replace
(TC_CLSFLOWER_REPLACE) call

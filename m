From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC] bpf: remove global verifier state
Date: Wed, 04 Oct 2017 21:13:47 +0200
Message-ID: <59D532EB.4000104@iogearbox.net>
References: <20171003201452.elth55atpquesjjk@ast-mbp.dhcp.thefacebook.com> <20171004002025.28521-1-jakub.kicinski@netronome.com> <20171004025226.wutfwm6hcsj4zuph@ast-mbp> <1507087446.8061.37.camel@edumazet-glaptop3.roam.corp.google.com> <20171004034311.t3uba7vqcvahly2q@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>, dsahern@gmail.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        david.beckett@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37836 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbdJDTNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 15:13:50 -0400
In-Reply-To: <20171004034311.t3uba7vqcvahly2q@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2017 05:43 AM, Alexei Starovoitov wrote:
> On Tue, Oct 03, 2017 at 08:24:06PM -0700, Eric Dumazet wrote:
>> On Tue, 2017-10-03 at 19:52 -0700, Alexei Starovoitov wrote:
>>
>>> yep. looks great.
>>> Please test it and submit officially :)
>>> The commit aafe6ae9cee3 ("bpf: dynamically allocate digest scratch buffer")
>>> fixed the other case where we were relying on the above mutex.
>>> The only other spot to be adjusted is to add spin_lock/mutex or DO_ONCE() to
>>> bpf_get_skb_set_tunnel_proto() to protect md_dst init.
>>> imo that would be it.
>>> Daniel, anything else comes to mind?

Yes, this should be all. DO_ONCE() for the tunnel proto seems a
good choice.

>> 16 MB of log (unswappable kernel memory) per active checker.
>>
>> We might offer a way to oom hosts.
>
> right. good point!
> we need to switch to continuous copy_to_user() after a page or so.
> Can even do it after every vscnprintf()
> but page at a time is probably faster.

Also worst case upper limits on verification side for holding state
aside from the log would need to be checked in terms of how much mem
we end up holding that is not accounted against any process (and not
really "rate-limited" anymore once we drop the mutex).

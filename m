From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/4] bpf: xdp: Allow head adjustment in XDP
 prog
Date: Wed, 07 Dec 2016 18:14:13 +0100
Message-ID: <58484365.4010201@iogearbox.net>
References: <5847D723.3020908@iogearbox.net>        <20161207114112.6ad86da3@jkicinski-Precision-T1700>        <20161207163756.GA33446@ast-mbp.thefacebook.com> <20161207.120413.939362482173997833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kubakici@wp.pl, kafai@fb.com, netdev@vger.kernel.org, ast@fb.com,
        bblanco@plumgrid.com, brouer@redhat.com, john.fastabend@gmail.com,
        saeedm@mellanox.com, tariqt@mellanox.com, kernel-team@fb.com
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43311 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752142AbcLGROU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:14:20 -0500
In-Reply-To: <20161207.120413.939362482173997833.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2016 06:04 PM, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Wed, 7 Dec 2016 08:37:58 -0800
>
>> On Wed, Dec 07, 2016 at 11:41:12AM +0000, Jakub Kicinski wrote:
>>>> I see nothing wrong if this is exposed/made visible in the usual way through
>>>> ethtool -k as well. I guess at least that would be the expected way to query
>>>> for such driver capabilities.
>>>
>>> +1 on exposing this to user space.  Whether via ethtool -k or a
>>> separate XDP-specific netlink message is mostly a question of whether
>>> we expect the need to expose more complex capabilities than bits.
>>
>> I'm very much against using NETIF_F_ flags and exposing this to user space.
>> I see this xdp feature flag as temporary workaround until all drivers
>> support adjust_head() helper. It is very much a fundamental feature for xdp.
>> Without being able to add/remove headers the usability of xdp becomes very limited.
>>
>> If you guys dont like extra ndo_xdp command, I'd suggest to do
>> "if (prog->xdp_adjust_head)" check in the driver and if driver doesn't
>> support it yet, just fail XDP_SETUP_PROG command.
>> imo that will be more flexible interface, since in the future drivers
>> can fail on different combination of features and simple boolean flag
>> unlikely to serve us for long time.
>
> Indeed, if the eventual plan is to have all drivers be required to
> support a fundamental set of XDP features then exporting this in any
> way to userspace is not a good idea.

Agreed, if that is required anyway, then much better and simpler to just
return the -ENOTSUPP from the XDP_SETUP_PROG handling of each driver that
way.

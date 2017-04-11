From: R Parameswaran <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v5 2/2] L2TP:Adjust intf MTU, add underlay L3, L2 hdrs.
Date: Tue, 11 Apr 2017 12:12:13 -0700
Message-ID: <CAGeBGG4z+cSturXncb_RqtsEsWCM6bVQaT=9nnjkc-_5HqwQwA@mail.gmail.com>
References: <alpine.DEB.2.11.1704051650420.19131@vera98.eng.brocade.com>
 <20170411104048.2lef7jl4f4qxqct3@alphalink.fr> <CAGeBGG5EJ8zeyGEeOkr8HHx9dZ98veRYM2Reb_gqQp21pNgJmQ@mail.gmail.com>
 <20170411170556.ciofp3nkttyhjwh3@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        James Chapman <jchapman@katalix.com>, kleptog@svana.org,
        Nachi Prachanda <nprachan@brocade.com>,
        Robert Shearman <rshearma@brocade.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Sven-Thorsten Dietrich <sdietric@brocade.com>,
        Chas Williams III <ciwillia@brocade.com>,
        Luca Boccassi <lboccass@brocade.com>,
        Derek Fawcus <dfawcus@brocade.com>,
        Bill Hong <bhong@brocade.com>,
        Jan Blunck <jblunck@brocade.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170411170556.ciofp3nkttyhjwh3@alphalink.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guillaume,

Please see inline:

On Tue, Apr 11, 2017 at 10:05 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Tue, Apr 11, 2017 at 09:39:58AM -0700, R Parameswaran wrote:
>> Hi Guillaume,
>>
>> On Tue, Apr 11, 2017 at 3:40 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
>> > On Wed, Apr 05, 2017 at 05:00:07PM -0700, R. Parameswaran wrote:
>> >>
>> >> Change-set here uses the new kernel function, kernel_sock_ip_overhead(),
>> >> to factor the outer IP overhead on the L2TP tunnel socket (including
>> >> IP Options, if any) when calculating the default MTU for an Ethernet
>> >> pseudowire, along with consideration of the inner Ethernet header.
>> >>
>> > I get the following warning with CONFIG_LOCKDEP when creating a new
>> > session:
>> > # ip l2tp add tunnel local 10.1.8.64 remote 10.1.8.32 udp_sport 1701 udp_dport 1701 tunnel_id 1 peer_tunnel_id 1
>> > # ip l2tp add session tunnel_id 1 session_id 1 peer_session_id 1
>> > ...
>>
>> Thanks for reporting this - I'll try and put up a patch soon,
>> hopefully the patch can stay in while I add this. One Q - how many CPU
>> cores do you have?
> This is a virtual machine with 4 vcores, but that shouldn't matter.
>
>> Can you give me some idea of how many tunnels and
>> sessions when you saw this?
>>
> Creating one session is enough. I simply used the following command:
> # ip l2tp add tunnel local 10.1.8.64 remote 10.1.8.32 udp_sport 1701 udp_dport 1701 tunnel_id 1 peer_tunnel_id 1
> # ip l2tp add session tunnel_id 1 session_id 1 peer_session_id 1
>
>> I did not see this warning in my testing, possibly because
>> CONFIG_LOCKDEP_SUPPORT is turned off on the product build? Will
>> re-test with this turned on.
>>
> Yes, enabling lockdep should let you reproduce the problem.
>
> The issue goes away if the tunnel's socket is locked while calling
> kernel_sock_ip_overhead():
> +       lock_sock(tunnel->sock);
>         kernel_sock_ip_overhead(tunnel->sock);
> +       release_sock(tunnel->sock);

Ack, thanks - was thinking along this line, since I see similar code
at other places in L2TP. I'll try and have a preliminary
patch out by tonight.

regards,

Ramkumar

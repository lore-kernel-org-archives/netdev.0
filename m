From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 3/7] openvswitch: Enable memory mapped Netlink i/o
Date: Tue, 3 Dec 2013 21:45:02 -0800
Message-ID: <CAEP_g=-LONa8uayCHYJ-Yve6PvxHJo7otWaZ80oYWeDC1Mjqmg@mail.gmail.com>
References: <cover.1385813891.git.tgraf@suug.ch> <9f7f05a726935c434d43d92c2908a997c403725b.1385813891.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:51420 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751298Ab3LDFp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 00:45:27 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so25208105ief.20
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 21:45:26 -0800 (PST)
In-Reply-To: <9f7f05a726935c434d43d92c2908a997c403725b.1385813891.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 30, 2013 at 4:21 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Use memory mapped Netlink i/o for all unicast openvswitch
> communication if a ring has been set up.
>
> Benchmark
>   * pktgen -> ovs internal port
>   * 5M pkts, 5M flows
>   * 4 threads, 8 cores
>
> Before:
> Result: OK: 67418743(c67108212+d310530) usec, 5000000 (9000byte,0frags)
>   74163pps 5339Mb/sec (5339736000bps) errors: 0
>         +   2.98%     ovs-vswitchd  [k] copy_user_generic_string
>         +   2.49%     ovs-vswitchd  [k] memcpy
>         +   1.84%       kpktgend_2  [k] memcpy
>         +   1.81%       kpktgend_1  [k] memcpy
>         +   1.81%       kpktgend_3  [k] memcpy
>         +   1.78%       kpktgend_0  [k] memcpy
>
> After:
> Result: OK: 24229690(c24127165+d102524) usec, 5000000 (9000byte,0frags)
>   206358pps 14857Mb/sec (14857776000bps) errors: 0
>         +   2.80%     ovs-vswitchd  [k] memcpy
>         +   1.31%       kpktgend_2  [k] memcpy
>         +   1.23%       kpktgend_0  [k] memcpy
>         +   1.09%       kpktgend_1  [k] memcpy
>         +   1.04%       kpktgend_3  [k] memcpy
>         +   0.96%     ovs-vswitchd  [k] copy_user_generic_string
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Reviewed-by: Daniel Borkmann <dborkman@redhat.com>

First three patches applied, thanks.

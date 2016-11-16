From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 16 Nov 2016 14:50:33 -0800
Message-ID: <47c129e9-100b-477e-6e44-e81ef746d55e@hpe.com>
References: <20140903165943.372b897b@redhat.com>
 <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hpe.com ([15.241.140.78]:9060 "EHLO
        g4t3425.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754094AbcKPWuf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:50:35 -0500
In-Reply-To: <20161116234022.2bad179b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 02:40 PM, Jesper Dangaard Brouer wrote:
> On Wed, 16 Nov 2016 09:46:37 -0800
> Rick Jones <rick.jones2@hpe.com> wrote:
>> It is a wild guess, but does setting SO_DONTROUTE affect whether or not
>> a connect() would have the desired effect?  That is there to protect
>> people from themselves (long story about people using UDP_STREAM to
>> stress improperly air-gapped systems during link up/down testing....)
>> It can be disabled with a test-specific -R 1 option, so your netperf
>> command would become:
>>
>> netperf -H 198.18.50.1 -t UDP_STREAM -l 120 -- -m 1472 -n -N -R 1
>
> Using -R 1 does not seem to help remove __ip_select_ident()

Bummer.  It was a wild guess anyway, since I was seeing a connect() call 
on the data socket.

> Samples: 56K of event 'cycles', Event count (approx.): 78628132661
>   Overhead  Command        Shared Object        Symbol
> +    9.11%  netperf        [kernel.vmlinux]     [k] __ip_select_ident
> +    6.98%  netperf        [kernel.vmlinux]     [k] _raw_spin_lock
> +    6.21%  swapper        [mlx5_core]          [k] mlx5e_poll_tx_cq
> +    5.03%  netperf        [kernel.vmlinux]     [k] copy_user_enhanced_fast_string
> +    4.69%  netperf        [kernel.vmlinux]     [k] __ip_make_skb
> +    4.63%  netperf        [kernel.vmlinux]     [k] skb_set_owner_w
> +    4.15%  swapper        [kernel.vmlinux]     [k] __slab_free
> +    3.80%  netperf        [mlx5_core]          [k] mlx5e_sq_xmit
> +    2.00%  swapper        [kernel.vmlinux]     [k] sock_wfree
> +    1.94%  netperf        netperf              [.] send_data
> +    1.92%  netperf        netperf              [.] send_omni_inner

Well, the next step I suppose is to have you try a quick netperf 
UDP_STREAM under strace to see if your netperf binary does what mine did:

strace -v -o /tmp/netperf.strace netperf -H 198.18.50.1 -t UDP_STREAM -l 
1 -- -m 1472 -n -N -R 1

And see if you see the connect() I saw. (Note, I make the runtime 1 second)

rick

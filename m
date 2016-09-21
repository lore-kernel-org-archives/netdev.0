From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Wed, 21 Sep 2016 10:57:34 +0300
Message-ID: <84150f05-7eb3-d35c-32fd-4b9853f6f114@gmail.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
 <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
 <20160920102943.24732097@brouer.com> <20160920133300.144037fd@redhat.com>
 <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
 <20160920154036.GA98644@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33076 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752679AbcIUH5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 03:57:38 -0400
Received: by mail-wm0-f47.google.com with SMTP id d66so27361045wmf.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 00:57:37 -0700 (PDT)
In-Reply-To: <20160920154036.GA98644@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 20/09/2016 6:40 PM, Alexei Starovoitov wrote:
> On Tue, Sep 20, 2016 at 03:53:10PM +0300, Tariq Toukan wrote:
>>>>> +	case XDP_ABORTED:
>>>> It is not clearly defined, but I believe XDP_ABORTED should also result
>>>> in a warning (calling bpf_warn_invalid_xdp_action(act)).
>> I'll add this.
> Certainly NOT.
> XDP_ABORTED is an exception case when program does divide by zero.
> It should NOT do bpf_warn. It must drop the packet.
> We discussed it several months ago.
> See mlx4/en_rx.c for canonical implementation.
>
This is also the example given here:
https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/xdp_actions.html#code-example

I prefer to align with the documentation (and with current mlx4 driver 
code), which means keeping the XDP_ABORTED w/o a warning.
Anyway, I don't think this should block the coming V2. If you decide to 
change documentation/specification, we will simply adjust our drivers 
accordingly.

Thanks,
Tariq.

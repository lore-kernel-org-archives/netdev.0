From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 15:53:10 +0300
Message-ID: <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
 <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
 <20160920102943.24732097@brouer.com> <20160920133300.144037fd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35381 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752028AbcITMxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 08:53:14 -0400
Received: by mail-wm0-f52.google.com with SMTP id l132so207674566wmf.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 05:53:13 -0700 (PDT)
In-Reply-To: <20160920133300.144037fd@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 20/09/2016 2:33 PM, Jesper Dangaard Brouer wrote:
> Resending, email didn't reach the list (used wrong sender email)
>
> On Tue, 20 Sep 2016 10:29:43 +0200 Jesper Dangaard Brouer <netdev@brouer.com> wrote:
>
>> On Mon, 19 Sep 2016 16:58:58 +0300 Tariq Toukan <tariqt@mellanox.com> wrote:
>>
>>> +	act = bpf_prog_run_xdp(prog, &xdp);
>>> +	switch (act) {
>>> +	case XDP_PASS:
>>> +		return false;
>>> +	case XDP_TX:
>>> +		consumed = mlx5e_xmit_xdp_frame(&rq->channel->xdp_sq, di,
>>> +						MLX5_RX_HEADROOM,
>>> +						len);
>>> +		rq->stats.xdp_tx += consumed;
>>> +		return consumed;
>>> +	default:
>>> +		bpf_warn_invalid_xdp_action(act);
>>> +		return false;
>> This looks wrong.  According to the specification[1] and comment in the
>> code /include/uapi/linux/bpf.h: "Unknown return codes will result in
>> packet drop"
I'll fix this.
>>> +	case XDP_ABORTED:
>> It is not clearly defined, but I believe XDP_ABORTED should also result
>> in a warning (calling bpf_warn_invalid_xdp_action(act)).
I'll add this.
>>
>>
>>> +	case XDP_DROP:
>>> +		rq->stats.xdp_drop++;
>>> +		mlx5e_page_release(rq, di, true);
>>> +		return true;
>>> +	}
>>
>> I've started documenting XDP[2], as this patch clearly shows there is a
>> need to have a specification, given already the second driver
>> supporting XDP gets these details wrong.
Indeed. Thanks for doing this.
>> [1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/xdp_actions.html#xdp-aborted
>>
>> [2] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html
>>
Regards,
Tariq

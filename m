From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] bpf, i40e: Report bpf_prog id during XDP_QUERY_PROG
Date: Wed, 21 Jun 2017 11:23:34 -0700
Message-ID: <CAKgT0Ucr2WANKLhXFfo2wearoeeNAMqNATMXkVLwxbDtrwKs9A@mail.gmail.com>
References: <754b16a0b2d98a1c6a3796aaa6701fae0c4e2612.1498065586.git.daniel@iogearbox.net>
 <594AB2EF.2040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33469 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdFUSXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 14:23:35 -0400
Received: by mail-qt0-f194.google.com with SMTP id c20so4427882qte.0
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 11:23:35 -0700 (PDT)
In-Reply-To: <594AB2EF.2040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 10:54 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 06/21/2017 10:27 AM, Daniel Borkmann wrote:
>> Fill the bpf_prog with the id just like we do in other XDP enabled
>> drivers.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Martin KaFai Lau <kafai@fb.com>
>> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index 2db93d3..6f5adb5 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -9589,6 +9589,7 @@ static int i40e_xdp(struct net_device *dev,
>>               return i40e_xdp_setup(vsi, xdp->prog);
>>       case XDP_QUERY_PROG:
>>               xdp->prog_attached = i40e_enabled_xdp_vsi(vsi);
>> +             xdp->prog_id = xdp->prog_attached ? vsi->xdp_prog->aux->id : 0;
>>               return 0;
>>       default:
>>               return -EINVAL;
>>
>
> Looks good to me.
>
> Acked-by: John Fastabend <john.fastabend@gmail.com>

My preference would be to test for vsi->xdp_prog instead of
xdp->prog_attached since it is more obvious what is going on in that
case. We might even want to look at getting rid of the call to
i40e_enabled_xdp_vsi eventually. But that is probably follow-up work
for later.

This should work assuming the RTNL lock is always held when this call is made.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

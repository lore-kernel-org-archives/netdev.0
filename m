From: Alexei Starovoitov <ast@fb.com>
Subject: Re: Alignment in BPF verifier
Date: Tue, 23 May 2017 16:59:50 -0700
Message-ID: <d4df095e-83bb-8bca-5fb5-7815cdc53d7c@fb.com>
References: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
 <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
 <bed5b512-6069-53cc-f128-05be05f89889@solarflare.com>
 <20170519.163957.1950740987459934279.davem@davemloft.net>
 <591F7A28.3020004@iogearbox.net>
 <f882c40e-bd50-f08e-afd8-f6396fc24ebc@solarflare.com>
 <748ff318-84dc-d338-67bd-2fd62ebcf3b8@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>,
        Josef Bacik <jbacik@fb.com>
To: Edward Cree <ecree@solarflare.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45301 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932943AbdEXAAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 20:00:33 -0400
In-Reply-To: <748ff318-84dc-d338-67bd-2fd62ebcf3b8@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/17 10:43 AM, Edward Cree wrote:
> Another issue: it looks like the min/max_value handling for subtraction is
>  bogus.  In adjust_reg_min_max_vals() we have
>     if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
>         dst_reg->min_value -= min_val;
>     if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
>         dst_reg->max_value -= max_val;
>  where min_val and max_val refer to the src_reg.
> But surely they should be used the other way round; if (say) 2 <= R1 <= 6
>  and 1 <= R2 <= 4, then this will claim 1 <= (R1 - R2) <= 2, whereas really
>  (R1 - R2) could be anything from -2 to 5.
> This also means that the code just above the switch,
>     if (min_val == BPF_REGISTER_MIN_RANGE)
>         dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
>     if (max_val == BPF_REGISTER_MAX_RANGE)
>         dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
>  is wrong, since e.g. subtracting MAX_RANGE needs to blow our min_value,
>  not our max_value.

right. good catch. I have a feeling we discussed similar thing before.
May be some patch felt through the cracks.
That's the reason the fancy verifier analysis is root only.
I'm assuming you're going to send a fix?
Thanks!

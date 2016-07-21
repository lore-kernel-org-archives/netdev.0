From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 2/2] net/mlx5e: Query minimum required header
 copy during xmit
Date: Thu, 21 Jul 2016 19:26:35 +0300
Message-ID: <CALzJLG_MX3eMZtw4D_RibeiOjgO8p1x_1=ObEBgUqwo=JJvgCg@mail.gmail.com>
References: <1469053202-30649-3-git-send-email-saeedm@mellanox.com>
 <20160721051529.GA89065@ast-mbp.thefacebook.com> <CALzJLG8jy-eRe9g93h1ChSdVN3ynON5f=KXH5_5rVMWqvn0-=Q@mail.gmail.com>
 <20160721.091514.851679663543797906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33193 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbcGUQ0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 12:26:55 -0400
Received: by mail-yw0-f194.google.com with SMTP id z8so4226724ywa.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 09:26:55 -0700 (PDT)
In-Reply-To: <20160721.091514.851679663543797906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 7:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Date: Thu, 21 Jul 2016 11:22:32 +0300
>
>> On Thu, Jul 21, 2016 at 8:15 AM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>>> On Thu, Jul 21, 2016 at 01:20:02AM +0300, Saeed Mahameed wrote:
>>>> From: Hadar Hen Zion <hadarh@mellanox.com>
>>>>
>>>> Add support for query the minimum inline mode from the Firmware.
>>>> It is required for correct TX steering according to L3/L4 packet
>>>> headers.
>>>>
>>>> Each send queue (SQ) has inline mode that defines the minimal required
>>>> headers that needs to be copied into the SQ WQE.
>>>> The driver asks the Firmware for the wqe_inline_mode device capability
>>>> value.  In case the device capability defined as "vport context" the
>>>> driver must check the reported min inline mode from the vport context
>>>> before creating its SQs.
>>>>
>>>> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>>>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>>> ...
>>>> +     int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
>>>> +     u32 *out;
>>>> +
>>>> +     out = mlx5_vzalloc(outlen);
>>>> +     if (!out)
>>>> +             return;
>>>
>>> Just discovered this...
>>> outlen is a small constant here, yet you want to try to vmalloc it?
>>> What is the point?
>>> There are 67 places in mlx5 where failed kmalloc is retried with
>>> vmalloc... was that path ever tested?
>>
>> The point is that there are a lot of places in the code that want to
>> allocate huge commands and mlx5_vzalloc is a nice black box that
>> provides the method to allocate such huge chunks of memory.
>
> If it's a "black box" then don't mention that it uses vmalloc in the
> function name.

Right, mlx5_zalloc would make a better name, I will change this in a
future refactoring patch.
but how is this related to this series ?

I am already working on a series for next kernel release to improve
mlx5 command interface, command layout allocation/filling and
execution.
I will be glad to listen to any suggestion you have regarding using
mlx5_vzalloc for small buffers allocation ..

Thanks,
Saeed.

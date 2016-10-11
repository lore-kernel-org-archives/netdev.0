From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: BUILD_BUG_ON error in mlx5/core/pagealloc.c
Date: Tue, 11 Oct 2016 16:34:18 +0900
Message-ID: <CALzJLG9HLz3y9jdcz+OsUCLhQyTrJxW3PYMz8kYRGRqay2S=HA@mail.gmail.com>
References: <CALx6S348UQF_oSqVSJ5h=K74_Q6cesR8g1Wf3rn14XRnRRBwgQ@mail.gmail.com>
 <CALx6S37sZFv2kEVmhAZru5H=rLqgW2nR7iSFUaPaJqV=eXNMMg@mail.gmail.com>
 <CALzJLG911C=Chxgy0Fm_jLf7s8L21yqmQA4fqfn909o3VgnvRg@mail.gmail.com> <CALx6S37nd2gVE4K7u49U9J_xJiaT8OU7Tc_fp29JDqi32WVVJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35285 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbcJKHel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 03:34:41 -0400
Received: by mail-lf0-f47.google.com with SMTP id l131so26588447lfl.2
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 00:34:40 -0700 (PDT)
In-Reply-To: <CALx6S37nd2gVE4K7u49U9J_xJiaT8OU7Tc_fp29JDqi32WVVJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 12:58 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Oct 10, 2016 at 8:17 PM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>>
>>
>> On Tuesday, October 11, 2016, Tom Herbert <tom@herbertland.com> wrote:
>>>
>>> On Mon, Oct 10, 2016 at 4:41 PM, Tom Herbert <tom@herbertland.com> wrot=
e:
>>> > I am hitting this in mlx5
>>> >
>>> > drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
>>> > =E2=80=98reclaim_pages_cmd.clone.0=E2=80=99:
>>> > drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
>>> > to =E2=80=98__compiletime_assert_346=E2=80=99 declared with attribute=
 error:
>>> > BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
>>> > drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
>>> > =E2=80=98give_pages=E2=80=99:
>>> > drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
>>> > to =E2=80=98__compiletime_assert_291=E2=80=99 declared with attribute=
 error:
>>> > BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64
>>> >
>>>
>>> The expression in BUILD_BUG_ON expands to "((unsigned)(unsigned
>>> long)(&(((struct mlx5_ifc_manage_pages_in_bits *)0)->pas[i]))) % 64".
>>> The variable array index to pas makes this expression non-constant, I
>>> imagine that is where the problem lies.
>>>
>>> > Bisecting points to:
>>> >
>>> > commit a533ed5e179cd15512d40282617909d3482a771c
>>> > Author: Saeed Mahameed <saeedm@mellanox.com>
>>> > Date:   Sun Jul 17 13:27:25 2016 +0300
>>> >
>>> >     net/mlx5: Pages management commands via mlx5 ifc
>>
>>
>> Hi Tom,
>> We know about this issue, it happens only with gcc4.4  or gcc 4.2 i don'=
t
>> remember exactly which.
>> Most likely it is a gcc issue.
>>
> I don't believe that is the case. As I pointed out this is giving
> BUILD_BUG_ON a non-constant expression. To fix this should just be a
> matter of using a constant argument for the BUILD_BUG_ON. AFAICT

Well, compilation work for us on most of our systems (where we have
newer gcc), something just doesn't add up here!
Anyway we didn't want to complicate the MACROs API and we wanted to
investigate a little bit more.

> there's only two instances of MLX5_SET64 where this can be a problem.
> I will post a fix shortly.

Thanks Tom, Just saw it, i will ack it.

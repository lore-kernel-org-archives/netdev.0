From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 26 May 2017 11:29:37 +0300
Message-ID: <CALzJLG9YNpagdJAcrh6O0jJhZWtsck6KigRtVxyjkArTm=82ew@mail.gmail.com>
References: <20170523114404.20387-1-saeedm@mellanox.com> <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp> <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com> <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilan Tayari <ilant@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35995 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970874AbdEZIaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:30:08 -0400
Received: by mail-qk0-f169.google.com with SMTP id u75so2485404qka.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:30:08 -0700 (PDT)
In-Reply-To: <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 11:48 PM, Jes Sorensen <jsorensen@fb.com> wrote:
> On 05/25/2017 06:40 AM, Saeed Mahameed wrote:
>>
>> On Thu, May 25, 2017 at 8:20 AM, Ilan Tayari <ilant@mellanox.com> wrote:
>>>>
>>>> -----Original Message-----
>>>> Can you put it into different driver? Dumping everything into by far
>>>> the biggest nic driver already is already huge headache in terms on
>>>> maintainability, debugging and back ports.
>>>> Look at how intel splits their drivers.
>>>> ixgb, ixgbe, ixgbevf are different drivers thought they have a lot in
>>>> common. On one side it's a bit of copy paste, but on the other side
>>
>>
>> I don't think the ixgb example is the same, simply  ixgb, ixgbe,
>> ixgbevf have different PCI IDs
>> and even different SW/FW interfaces. On the other hand, same mlx5
>> driver can support all of
>> ConnetX4/5/6 device IDs with the same code flows, same interfaces.
>>
>>>> it makes drivers much easier to develop and maintain independently.
>>>> ConnectX-6 code and any future hw support doesn't belong to
>>>> mlx5 driver at all.
>>
>>
>> Sorry i must disagree with you on this for the same reasons Ilan
>> mentioned.
>> We can perfectly achieve the same with modular driver design all under the
>> same .ko module, with some kconfig flags to reduce the amount of
>> code/features
>> this .ko provides.
>
>
> If I get this right, the FPGA is independent and could in theory be used for
> non network stuff. It really should have it's own driver in that case, and
> you should provide accessor functionality via the mlx5 driver.
>

Hi Jes,

No, It is clearly stated in the commit message :

"The FPGA is a bump-on-the-wire and thus affects operation of
the mlx5_core driver on the ConnectX ASIC."

Which means mlx5 FPGA user can only write logic which affects only
packets going in/out
A ConnectX chip - so it is only network stuff -.

> We have this with other devices in the kernel where a primary device driver
> provides an interface for an additional sub-driver to access another device
> behind it. Like bt-coexist in some of the wifi drivers allowing access to a
> bluetooth device behind it.
>

Blutooth over wifi or vise versa is a very good example to what you
are requesting.
But, it doesn't fit to what we are trying to do here. mlx5 FGPA is a
ConnectX card feature, not a new protocol.

> Jes

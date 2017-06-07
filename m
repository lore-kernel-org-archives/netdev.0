From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Wed, 7 Jun 2017 06:47:02 +0300
Message-ID: <CALzJLG-XbvWAUmij7NVRDnUN7gtPm=Bf5MNigmgHOZEX5W447g@mail.gmail.com>
References: <20170606183457.fg7vgv2zji3fhlb5@ast-mbp.dhcp.thefacebook.com>
 <20170606.143824.717466091308335341.davem@davemloft.net> <20170606185532.2byjdonwsyan2asl@ast-mbp.dhcp.thefacebook.com>
 <20170606.150151.1650636686526694540.davem@davemloft.net> <20170606224451.76732gjmf6vaetxx@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jes Sorensen <jsorensen-b10kYP2dOMg@public.gmane.org>,
        andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170606224451.76732gjmf6vaetxx@ast-mbp>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 7, 2017 at 1:44 AM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Jun 06, 2017 at 03:01:51PM -0400, David Miller wrote:
>> From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Tue, 6 Jun 2017 11:55:33 -0700
>>
>> > If in the future mlx will make it into the nic in a way that
>> > encryption shares all memory management logic and there is no fpga
>> > at all then it indeed will be similar to tc offload. Right now it's
>> > not and needs different sw architecture.
>>
>> If the visible effect is identical, I fundamentally disagree with you.
>>
>> I don't care if there is a frog sitting on the PHY that transforms
>> the packets, it's all the same if the visible behavior is identical.
>
> that frog is a good example why we disagree.
> I need to check the pulse of that frog and last time it ate.
> In production I cannot have magical creatures do stuff for me.
> I need to monitor all components, debug and mitigate the issues.

Every HW vendor has his own magical creatures. you don't want just to
have a kernel object representative for every HW unit!
that's just not scalable.

> If encryption is done by the nic, I get all the monitoring and
> debugging as part of the standard tools. When it's a frog
> hidden by the nic, I cannot do much when the fire erupts,
> hence frog and production environment don't mix.
> To move things forward...

Let's assume there was no FPGA but the ASIC provided the encryption
feature, and still a fire erupts,
what would you have done differently ? Only the vendor will know how
to debug regardless of what creature went nuts!

Frog or a Cat the kernel shouldn't care much "it is all implementation
details (HW implementation)", we should use the entry point to this
device (PCI device/netdevice)
as an abstraction point, and standardizing visibility/debuggability
should be per 'kernel<->stack<->driver<->HW'
features/flows/transactions.
Having a full driver<->HW visibility/standardization eliminates the
need of vendor specific drivers and each vendor should implement only
standard HWs that can work with generic drivers.

Re debuggability in ConnectX architecture, there is a well defined
health reporting and monitoring mechanism between FW and driver.
and it is up to the FW to check the pulse of every frog it is
babysitting and report back to the driver.
believe me you don't want the driver to know about every single wire
in the chip.

> how about marking the whole thing CONFIG_EXPERIMENTAL instead of revert?
> Right now it's effectively non-production==experimental code and
> I want to make it clear.
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

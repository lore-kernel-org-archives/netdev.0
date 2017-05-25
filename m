From: Jes Sorensen <jsorensen-b10kYP2dOMg@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Thu, 25 May 2017 16:48:22 -0400
Message-ID: <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/25/2017 06:40 AM, Saeed Mahameed wrote:
> On Thu, May 25, 2017 at 8:20 AM, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>>> -----Original Message-----
>>> Can you put it into different driver? Dumping everything into by far
>>> the biggest nic driver already is already huge headache in terms on
>>> maintainability, debugging and back ports.
>>> Look at how intel splits their drivers.
>>> ixgb, ixgbe, ixgbevf are different drivers thought they have a lot in
>>> common. On one side it's a bit of copy paste, but on the other side
> 
> I don't think the ixgb example is the same, simply  ixgb, ixgbe,
> ixgbevf have different PCI IDs
> and even different SW/FW interfaces. On the other hand, same mlx5
> driver can support all of
> ConnetX4/5/6 device IDs with the same code flows, same interfaces.
> 
>>> it makes drivers much easier to develop and maintain independently.
>>> ConnectX-6 code and any future hw support doesn't belong to
>>> mlx5 driver at all.
> 
> Sorry i must disagree with you on this for the same reasons Ilan mentioned.
> We can perfectly achieve the same with modular driver design all under the
> same .ko module, with some kconfig flags to reduce the amount of code/features
> this .ko provides.

If I get this right, the FPGA is independent and could in theory be used 
for non network stuff. It really should have it's own driver in that 
case, and you should provide accessor functionality via the mlx5 driver.

We have this with other devices in the kernel where a primary device 
driver provides an interface for an additional sub-driver to access 
another device behind it. Like bt-coexist in some of the wifi drivers 
allowing access to a bluetooth device behind it.

Jes
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

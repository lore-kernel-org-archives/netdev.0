From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 26 May 2017 10:56:25 -0700
Message-ID: <20170526175624.5xxflpf24je5673h@ast-mbp>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp>
 <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>,
        Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alan Tull <atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>, yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 26, 2017 at 11:59:26AM +0300, Saeed Mahameed wrote:
> 
> And for FPGA support, we did it correctly this time, all the new code
> is under mlx5/core/fgpa ..

s/correctly/incorrectly/ ?

> Well, this is a well known dilemma, if one has a new feature and has no sandbox
> area to put it in the first phase, it is better to start from the most
> common place
> for that feature which is the originating place, before defining
> APIs/infrastructures,
> until the feature is complete and every body is happy about it.

There is driver/fpga to manage fpga, but mlx fpga+nic combo
will be managed via mlx5/core/fpga/

Adding fpga folks for visibility.

> 1. eswitch is a very integral steering feature of the ConnectX family
> and is valid for all ConnectX4/lx/5/6 .. cards.

and kernel has no visibility into it and mlx has no incentive to expose it,
since community needs to agree on api whereas hiding in the driver
is 'mlx territory' and much easier to push arbitrary patches to.

> "The FPGA is a bump-on-the-wire and thus affects operation of
> the mlx5_core driver on the ConnectX ASIC."
> 
> This is not a general purpose FPGA ! it even doesn't have a PCI Id or
> it is own PCI function.
> it simply allows the ConnectX Chip user to inspect/inject or run user
> specif login on traffic going in/out of the chip.

... and bluefield arm cpus are not general purpose cpus and
only used to offload networking just like this fpga?

> But i agree with you some serious API brainstorming should be
> considered, but not at this stage,
> this patch only tells the ConnectX card (if you have FPGA, please enable it).

serious api discussion needs be done before things like eswitch, fpga
exposed to users otherwise we end up in the eswitch situation that
drops packets based on its own invisible logic, but with hidden fpga
it will be even more obscure.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

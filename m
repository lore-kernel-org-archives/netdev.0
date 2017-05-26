From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 26 May 2017 12:15:17 -0600
Message-ID: <20170526181517.GA3860@obsidianresearch.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
 <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
 <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170526030701.du4345mbprhcwjyi@ast-mbp>
 <CALzJLG98D=3yMJV_q4sjVNG41AERFRU+6rwqQJsxnRuVeDTPdA@mail.gmail.com>
 <20170526175624.5xxflpf24je5673h@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>,
        Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alan Tull <atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>, yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170526175624.5xxflpf24je5673h@ast-mbp>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 26, 2017 at 10:56:25AM -0700, Alexei Starovoitov wrote:

> > for that feature which is the originating place, before defining
> > APIs/infrastructures,
> > until the feature is complete and every body is happy about it.
> 
> There is driver/fpga to manage fpga, but mlx fpga+nic combo
> will be managed via mlx5/core/fpga/
> 
> Adding fpga folks for visibility.

It would be good to use the existing fpga loading infrastructure to
get the bitstream into the NIC, and to use the same Xilinx bitstream
format as eg Zynq does for consistency.

I'm unclear how this works - there must be more to it than just a
'bump on the wire', there must be some communication channel between
the FPGA and Linux to set operational data (eg load keys) etc.

If that is register mapped into a PCI-BAR someplace then it really
should use the FPGA layer functions to manage binding drivers to that
register window.

If it is mailbox command based then it is not as good of a fit.

Is this FPGA expected to be customer programmable? In that case you
really need the full infrastructure to bind the right driver (possibly
a customer driver) to the current FPGA, to expose the correct
operational interface to the kernel.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

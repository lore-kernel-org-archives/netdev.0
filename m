From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Wed, 7 Jun 2017 09:48:58 -0600
Message-ID: <20170607154858.GA30124@obsidianresearch.com>
References: <AM4PR0501MB1940D05A19F098286B99EAD0DBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170529160252.GA27550@obsidianresearch.com>
 <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <AM4PR0501MB19409139227E11A4A7F82F0FDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170601153704.GA1680@obsidianresearch.com>
 <AM4PR0501MB19404B83A69B87AFB1326B45DBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170605151724.GA20182@obsidianresearch.com>
 <AM4PR0501MB194008AAABEB6AAAA2ADFC82DBCB0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170606161709.GA8671@obsidianresearch.com>
 <CALzJLG9Rdjme2piWX+CDeHZZebWArM_wGjLJPh8=COOxBHuFkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilan Tayari <ilant@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "jsorensen@fb.com" <jsorensen@fb.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        "linux-fpga@vger.kernel.org" <linux-fpga@vger.kernel.org>,
        Alan Tull <atull@opensource.altera.com>,
        "yi1.li@linux.intel.com" <yi1.li@linux.intel.com>,
        Boris Pismenny <borisp@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:43828 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750831AbdFGPtN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 11:49:13 -0400
Content-Disposition: inline
In-Reply-To: <CALzJLG9Rdjme2piWX+CDeHZZebWArM_wGjLJPh8=COOxBHuFkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 07:16:42AM +0300, Saeed Mahameed wrote:
> On Tue, Jun 6, 2017 at 7:17 PM, Jason Gunthorpe
> <jgunthorpe@obsidianresearch.com> wrote:
> > On Tue, Jun 06, 2017 at 06:52:15AM +0000, Ilan Tayari wrote:
> >
> >> So neither the host stack nor the network are aware of them.
> >> They exist momentarily only on the internal traces on the board and not
> >> anywhere else.
> >
> > Is that really true? If you are creating rocee QPs' then the RDMA
> > stack sees this stuff and now we have buried a RDMA ULP inside an
> > ethernet driver which seems really wonky..
> 
> It is not an ethernet driver, mlx5_core provides both RDMA and
> ethernet interfaces to both mlx5_ib and the mlx5e netdevice.
> 
> so it is perfectly capable of creating QPs on its own, after all it is
> the one creating QPs for the RDMA stack :).
> 
> rdma_create_qp->mlx5_ib_create_qp->mlx5_core_create_qp.

Wait, so you built a RDMA ULP inside your driver without using the
RDMA API?

This keep getting more ugly :(

What about security? What if user space sends some raw packets to the
FPGA - can it reprogram the ISPEC settings or worse?

Jason

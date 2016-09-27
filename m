From: Adit Ranadive <aditr@vmware.com>
Subject: Re: [PATCH v5 13/16] IB/pvrdma: Add the main driver module for PVRDMA
Date: Tue, 27 Sep 2016 11:50:44 -0700
Message-ID: <979bf690-1566-8674-5c46-4108006fb32a@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
 <8db982c37a0a96b37df02826564474a216922f25.1474759181.git.aditr@vmware.com>
 <20160926072739.GB6352@yuval-lap.Home>
 <651b18ee-55ca-0c72-af9c-c55c42b57fd1@vmware.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A6EA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "jhansen@vmware.com" <jhansen@vmware.com>,
        "asarwade@vmware.com" <asarwade@vmware.com>,
        "georgezhang@vmware.com" <georgezhang@vmware.com>,
        "bryantan@vmware.com" <bryantan@vmware.com>
To: David Laight <David.Laight@ACULAB.COM>,
        Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB010A6EA@AcuExch.aculab.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 09:21:27AM +0000, David Laight wrote:
> From: Adit Ranadive
> > Sent: 26 September 2016 19:15
> > On Mon, Sep 26, 2016 at 00:27:40AM -0700, Yuval Shaia wrote:
> > > On Sat, Sep 24, 2016 at 04:21:37PM -0700, Adit Ranadive wrote:
> > > > +
> > > > +	/* Currently, the driver only supports RoCE mode. */
> > > > +	if (dev->dsr->caps.mode != PVRDMA_DEVICE_MODE_ROCE) {
> > > > +		dev_err(&pdev->dev, "unsupported transport %d\n",
> > > > +			dev->dsr->caps.mode);
> > > > +		ret = -EINVAL;
> > >
> > > This is some fatal error with the device, not that something wrong with the
> > > function's argument.
> > > Suggesting to replace with -EFAULT.
> > >
> > 
> > Thanks, will fix this one and the others here.
> 
> Won't EFAULT generate SIGSEGV ?

Since this is called at module load time, wouldn't the module load fail with
this error rather than generate a SIGSEGV?

I'm slightly unclear about what would if it is compiled into the kernel though
I think it should fail with the error.

The only other error value to return here that could make sense is EIO.

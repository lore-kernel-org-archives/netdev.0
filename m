From: Myron Stowe <mstowe@redhat.com>
Subject: Re: [PATCH 0/2] Replace driver's usage of hard-coded device IDs to
 #defines
Date: Thu, 25 May 2017 09:56:55 -0600
Message-ID: <20170525095655.3a577ea2@zim>
References: <20170524224734.24221.33787.stgit@amt.stowe>
        <20170524.200249.1492095559302424098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: myron.stowe@redhat.com, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, bhelgaas@google.com, saeedm@mellanox.com,
        noaos@mellanox.com, tariqt@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170524.200249.1492095559302424098.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2017 20:02:49 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Myron Stowe <myron.stowe@redhat.com>
> Date: Wed, 24 May 2017 16:47:34 -0600
> 
> > Noa Osherovich introduced a series of new Mellanox device ID
> > definitions to help differentiate specific controllers that needed
> > INTx masking quirks [1].
> > 
> > Bjorn Helgaas followed on, using the device ID definitions Noa
> > provided to replace hard-coded values within the mxl4 ID table [2].
> >     
> > This patch continues along similar lines, adding a few additional
> > Mellanox device ID definitions and converting the net/mlx5e
> > driver's mlx5 ID table to use the defines so tools like 'grep' and
> > 'cscope' can be used to help identify relationships with other
> > aspects (such as INTx masking).  
> 
> If you're adding pci_ids.h defines, it's only valid to do so if you
> actually use the defines in more than one location.
> 
> This patch series is not doing that.

Hi David,

Yes, now that you mention that again I do vaguely remember past
conversations stating similar constraints which is a little odd as
Noa's series did exactly that.  It was Bjorn, in a separate patch, that
made the connection to the driver with commit c19e4b9037f
("net/mlx4_core: Use device ID defines") [1] and even after such, some
of the introduced #defines are still currently singular in usage.

Anyway, the part I'm interested in is creating a more transparent
association between the Mellanox controllers that need the INTx masking
quirk and their drivers, something that remains very opaque currently
for a few of the remaining instances (PCI_DEVICE_ID_MELLANOX_CONNECTIB,
PCI_DEVICE_ID_MELLANOX_CONNECTX4, and
PCI_DEVICE_ID_MELLANOX_CONNECTX4_LX).

I'd like to hear back from others as to whether or not there is truly
concern about adding the #defines such as I submitted with singular
usages and if so I can re-submit a more focused patch which would
effectively be the first three substitutions in "[PATCH 2/2] net/mlx5e:
Use device ID defines".


[1] Perhaps Noa's submission had a similar discussion as while it was
a separate series from which Bjorn then made the connection to the
driver, all the patches came in via the same merge commit 25831571419
("Merge branch 'pci/virtualization' into next").


 Thanks for your
feedback,
 Myron

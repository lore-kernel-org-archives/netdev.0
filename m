From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH RFC] pci: Control whether VFs are probed on
 pci_enable_sriov
Date: Mon, 8 Dec 2014 20:52:04 +0200
Message-ID: <20141208185204.GB24790@mtldesk30>
References: <1417957693-24979-1-git-send-email-eli@mellanox.com>
 <B5657A6538887040AD3A81F1008BEC63BA6616@avmb3.qlogic.org>
 <5484C77D.7060501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>,
	linux-pci <linux-pci@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yevgenyp@mellanox.com" <yevgenyp@mellanox.com>
To: Don Dutile <ddutile@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5484C77D.7060501@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 07, 2014 at 04:32:45PM -0500, Don Dutile wrote:
> >
> >Does a one-shot flag suffice? E.g., consider assigning a VF to VM and
> >than shutting down the VM. Assuming this feature is disabled,
> >the VF didn't appear on the hypervisor prior to the assignment but
> >will appear after its shutdown.
> >
> +1 to this question.
> All I see is a one-shot savings in VF configuration time at pci_sriov_enable() time.
> Please explain why this is so important for mlx5 (sriov) operation?
> 

This is not a specific mlx5 requirement. The rational is that you
don't want to probe the virtual fucntions at the hypervisor just
because they appear there all of the sudden. You are likely to want to
assign some of them to VMs so why probe them and then remove them? It
makes sense to me that other drivers would also like this kind of
fucntionality.

> Can the vf driver probe be called & exit early the first time, and perform full
> (host) configuration thereafter?
>

Yes, this can be done but I was thinking that other drivers could also
benefit from such functionality.

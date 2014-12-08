From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH RFC] pci: Control whether VFs are probed on
 pci_enable_sriov
Date: Mon, 8 Dec 2014 21:10:32 +0200
Message-ID: <20141208191032.GC24790@mtldesk30>
References: <1417957693-24979-1-git-send-email-eli@mellanox.com>
 <B5657A6538887040AD3A81F1008BEC63BA6616@avmb3.qlogic.org>
 <20141207184242.GA24790@mtldesk30>
 <B5657A6538887040AD3A81F1008BEC63BA669B@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli@dev.mellanox.co.il>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>,
	linux-pci <linux-pci@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yevgenyp@mellanox.com" <yevgenyp@mellanox.com>,
	Donald Dutile <ddutile@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63BA669B@avmb3.qlogic.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 07, 2014 at 08:08:47PM +0000, Yuval Mintz wrote:
> >>>Use a parameter to pci_enable_sriov to control that policy, and modify
> >>>all current callers such that they retain the same functionality.
> >> 
> >> What's the end-game here? How eventually would this be controlled?
> 
> >You can probe any VF at the hypervisor through sysfs files
> >(bind/unbind). You can also pass them through to a VM. Nothing
> >changes.
> 
> If you're not planning on adding a logic to set this, why do we need to
> add a parameter to pci_enable_sriov() - given that all callers use the
> exact same logic?
> [And I don't really think we'd want different devices to behave differently
> by default; That would be confusing for users.]
> 
Currently the kerenl will call probe for any device for which there is
a supporting driver and I did not want to change that.

> >>>Use a one shot flag on struct pci_device which is cleared after the
> >>>first probe is ignored so subsequent attempts go through.
> >>
> >> Does a one-shot flag suffice? E.g., consider assigning a VF to VM and
> >> than shutting down the VM. Assuming this feature is disabled,
> >> the VF didn't appear on the hypervisor prior to the assignment but
> >> will appear after its shutdown.
> 
> >Sorry, I don't follow you here. Please clarify.
> 
> >To be clear, the functionality proposed here is really one shot. It
> >just prevents calling probe once; besides that nothing changes.
> 
> What I meant is that device is unbinded after initial probe,
> But in the scenario I've stated above, the VF will become binded once
> it's returned to the hypervisor.
> Now, I understand that what you're trying to achieve - but my question
> is whether what you're REALLY trying to achieve is the ability to have VFs
> which would only be binded to VMs and never to hypervisor [by default]?

No this was not my intention. I guess any driver that wishes to
achieve the same functionality can simply ignore the N first probes after
the call to pci_enable_sriov() where N is the number of VFs it
created.

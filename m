From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH 0/2] igb/ixgbe: Fix ordering of SR-IOV teardown
Date: Wed, 29 Jul 2015 13:33:07 -0600
Message-ID: <1438198387.13460.68.camel@redhat.com>
References: <20150727223753.10121.78169.stgit@gimli.home>
	 <20150729.121630.2264285348757503000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150729.121630.2264285348757503000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-29 at 12:16 -0700, David Miller wrote:
> From: Alex Williamson <alex.williamson@redhat.com>
> Date: Mon, 27 Jul 2015 17:18:28 -0600
> 
> > When running a Windows 2012 R2 guest with a pair of VFs assigned
> > through vfio-pci, we run into a problem trying to hot-unplug those VFs
> > after the PF has unregistered the netdev.  This is a common scenario
> > if the PF is unbound from the driver while VFs are active.  In the
> > case of igb, the resulting guest behavior differs slightly between the
> > Microsoft provided and Intel add-on guest drivers.  With the Microsoft
> > driver, the guest seems to stumble through ejecting both VFs, but
> > takes longer than normal to do so.  With the Intel drivers, only one
> > VF is unplugged, but Device Manager still shows it as present.  The
> > second VF is non-functional but also still shown in Device Manager.
> > At this point, the guest is in such a state that it will not cleanly
> > shutdown.  With ixgbe VFs, both the Microsoft and Intel drivers take
> > on this latter behavior.
> > 
> > For both, I've found that disabling SR-IOV before unregistering the PF
> > netdev device allows the hot-unplug to proceed without interruption or
> > further ill behavior in the guest.  This is true regardless of which
> > driver is used.  I don't fully understand what dependency is broken
> > by unregistering the netdev prior to disabling SR-IOV, but I also
> > don't see the benefit in delaying SR-IOV teardown in this call path.
> > It could potentially be moved even earlier, but I'll let those more
> > familiar with the hardware and code make that determination.  In any
> > case, the VM behavior is substantially improved by this slight
> > re-ordering.
> > 
> > I don't have an i40e for testing, but it already appears to disable
> > SR-IOV much earlier in the unbind path, so I wouldn't expect to find
> > similar issues.  Thanks,
> 
> Patch #2 does not apply cleanly, please respin this series against
> my 'net' GIT tree, thanks.

I expect that's because of this patch that's in Jeff's dev-queue branch:

http://git.kernel.org/cgit/linux/kernel/git/jkirsher/next-queue.git/commit/?h=dev-queue&id=ddf766a812a13eca1116b5905e902184904266f9

I based these patches off that branch, assuming they'd take the same
route and avoid the merge conflict.  If you'd rather take these, I'll be
happy to respin.  Apologies for not noting the base branch in the
series.  Thanks,

Alex

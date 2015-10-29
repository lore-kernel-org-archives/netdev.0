From: Lan Tianyu <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV
 NIC
Date: Thu, 29 Oct 2015 16:33:06 +0800
Message-ID: <5631D9C2.2040206@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com> <562A7E33.4080800@gmail.com> <562DBBC9.4000104@intel.com> <562E40BB.6040404@gmail.com> <5631B8CA.9040805@intel.com> <5631C3A7.2070900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Duyck <alexander.duyck@gmail.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5631C3A7.2070900@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015=E5=B9=B410=E6=9C=8829=E6=97=A5 14:58, Alexander Duyck wrote:
>=20
> Your code was having to do a bunch of shuffling in order to get thing=
s
> set up so that you could bring the interface back up.  I would argue
> that it may actually be faster at least on the bring-up to just drop =
the
> old rings and start over since it greatly reduced the complexity and =
the
> amount of device related data that has to be moved.

If give up the old ring after migration and keep DMA running before
stopping VCPU, it seems we don't need to track Tx/Rx descriptor ring an=
d
just make sure that all Rx buffers delivered to stack has been migrated=
=2E

1) Dummy write Rx buffer before checking Rx descriptor to ensure packet
migrated first.

2) Make a copy of Rx descriptor and then use the copied data to check
buffer status. Not use the original descriptor because it won't be
migrated and migration may happen between two access of the Rx descript=
or.

--=20
Best regards
Tianyu Lan

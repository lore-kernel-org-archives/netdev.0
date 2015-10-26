From: Lan Tianyu <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV
 NIC
Date: Mon, 26 Oct 2015 13:36:09 +0800
Message-ID: <562DBBC9.4000104@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com> <562A7E33.4080800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <562A7E33.4080800@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015=E5=B9=B410=E6=9C=8824=E6=97=A5 02:36, Alexander Duyck wrote:
> I was thinking about it and I am pretty sure the dummy write approach=
 is
> problematic at best.  Specifically the issue is that while you are
> performing a dummy write you risk pulling in descriptors for data tha=
t
> hasn't been dummy written to yet.  So when you resume and restore you=
r
> descriptors you will have once that may contain Rx descriptors
> indicating they contain data when after the migration they don't.

How about changing sequence? dummy writing Rx packet data fist and then
its desc. This can ensure that RX data is migrated before its desc and
prevent such case.

--=20
Best regards
Tianyu Lan

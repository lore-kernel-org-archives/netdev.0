From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ixgbevf: Fix relaxed order settings in VF driver
Date: Thu, 21 Apr 2016 11:13:37 -0700
Message-ID: <CAKgT0UeU+Q1HDvR8pK3kxYofjEqk8jVeh5xONoUpD34MsPZCCA@mail.gmail.com>
References: <1461259276-54151-1-git-send-email-babu.moger@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Babu Moger <babu.moger@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461259276-54151-1-git-send-email-babu.moger@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2016 at 10:21 AM, Babu Moger <babu.moger@oracle.com> wrote:
> Current code writes the tx/rx relaxed order without reading it first.
> This can lead to unintended consequences as we are forcibly writing
> other bits.

The consequences were very much intended as there are situations where
enabling relaxed ordering can lead to data corruption.

> We noticed this problem while testing VF driver on sparc. Relaxed
> order settings for rx queue were all messed up which was causing
> performance drop with VF interface.

What additional relaxed ordering bits are you enabling on Sparc?  I'm
assuming it is just the Rx data write back but I want to verify.

> Fixed it by reading the registers first and setting the specific
> bit of interest. With this change we are able to match the bandwidth
> equivalent to PF interface.
>
> Signed-off-by: Babu Moger <babu.moger@oracle.com>

Fixed is a relative term here since you are only chasing performance
from what I can tell.  We need to make certain that this doesn't break
the driver on any other architectures by leading to things like data
corruption.

- Alex

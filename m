From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] [PCI] move ICHx GbE NVM write-protection from e1000e to PCI quirk
Date: Fri, 24 Oct 2008 18:27:19 -0700
Message-ID: <9929d2390810241827o4b0f525dt1e34b4f17ddad4a6@mail.gmail.com>
References: <20081025011358.9975.77556.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	jbarnes@virtuousgeek.org, "Bruce Allan" <bruce.w.allan@intel.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20081025011358.9975.77556.stgit@gitlost.lost>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 24, 2008 at 6:13 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
>
> The write-protection method being in the driver probe routine is called
> late in the boot sequence, and not at all if the driver is never loaded.
> By making it a PCI quirk the NVM is protected much earlier whether or not
> the driver is loaded.  The write-protection quirk can be disabled with a
> new kernel parameter in the unlikely event the NVM needs to be modified.
>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
>  Documentation/kernel-parameters.txt |    4 +
>  drivers/net/Makefile                |    1
>  drivers/net/e1000e/Makefile         |    1
>  drivers/net/e1000e/e1000.h          |    1
>  drivers/net/e1000e/ethtool.c        |    6 +
>  drivers/net/e1000e/ich8lan.c        |   93 +++-----------------
>  drivers/net/e1000e/ich8lan.h        |   68 +++++++++++++++
>  drivers/net/e1000e/netdev.c         |    4 -
>  drivers/net/e1000e/param.c          |   30 ------
>  drivers/net/e1000e/quirks.c         |  162 +++++++++++++++++++++++++++++++++++
>  10 files changed, 256 insertions(+), 114 deletions(-)
>  create mode 100644 drivers/net/e1000e/ich8lan.h
>  create mode 100644 drivers/net/e1000e/quirks.c
>
>

This PCI quirk is put in ./drivers/net/e1000e in order to share
defines and structs found in the driver source, and is only applicable
to ICHx GbE LOMs supported by that driver anyway.

-- 
Cheers,
Jeff

From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Sun, 23 Nov 2014 18:21:47 +0200
Message-ID: <5472099B.5070105@mellanox.com>
References: <1416653807-4859-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <yishaih@mellanox.com>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0058.outbound.protection.outlook.com ([157.56.112.58]:52288
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751407AbaKWQ4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2014 11:56:37 -0500
In-Reply-To: <1416653807-4859-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2014 12:56 PM, Gavin Shan wrote:
> The patch fixes couple of EEH recovery failures on PPC PowerNV
> platform:
> 
>    * Release reserved memory regions in mlx4_pci_err_detected().
>      Otherwise, __mlx4_init_one() fails because of reserving
>      same memory regions recursively.
>    * Disable PCI device in mlx4_pci_err_detected(). Otherwise,
>      pci_enable_device() in __mlx4_init_one() doesn't enable
>      the PCI device because it's already in enabled state indicated
>      by struct pci_dev::enable_cnt.
>    * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
>      Otherwise, __mlx4_init_one() runs into kernel crash because
>      of dereferencing to NULL pointer.
> 
> With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
> PowerNV platform.
> 
>    # lspci
>    0003:0f:00.0 Network controller: Mellanox Technologies \
>    MT27500 Family [ConnectX-3]
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

Hi Gavin,

Yishai (added to the CC) is few days before sending a patchset to fix
the reset flow and inside it there is a fix to EEH recovery.
I would be happy if you could wait for the whole reset flow fix by Yishai.

If you'd like, I can send you the patchset to try. Currently it is under
review inside Mellanox before being sent to the mailing list.

Thanks,
Amir

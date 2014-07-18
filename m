From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 09:28:54 -0700
Message-ID: <1405700934.605.31.camel@jarvis.lan>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-kernel@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
 linux-acenic@sunsite.dk, linux-scsi@vger.kernel.org,
 linux-rdma@vger.kernel.org, ath10k@lists.infradead.org, linux-hippi@sunsite.dk,
 industrypack-devel@lists.sourceforge.net, linux-mmc@vger.kernel.org,
 MPT-FusionLinux.pdl@avagotech.com, virtualization@lists.linux-foundation.org,
 ath9k-devel@venema.h4ckr.net, wil6210@qca.qualcomm.com,
 linux-pcmcia@lists.infradead.org, linux-can@vger.kernel.org,
 xen-devel@lists.xenproject.org, platform-driver-x86@vger.kernel.org,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 users@rt2x00.serialmonkey.com, e1000-devel@lists.sourceforge.net,
 linux-crypto@vger.kernel.org, devel@linuxdriverproject.org
To: Benoit Taine <benoit.taine@lip6.fr>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Fri, 2014-07-18 at 17:26 +0200, Benoit Taine wrote:
> We should prefer `const struct pci_device_id` over
> `DEFINE_PCI_DEVICE_TABLE` to meet kernel coding style guidelines.
> This issue was reported by checkpatch.

What kernel coding style?  checkpatch isn't the arbiter of style, if
that's the only problem.

The DEFINE_PCI macro was a well reasoned addition when it was added in
2008.  The problem was most people were getting the definition wrong.
When we converted away from CONFIG_HOTPLUG, having this DEFINE_ meant
that only one place needed changing instead of hundreds for PCI tables.

The reason people were getting the PCI table wrong was mostly the init
section specifiers which are now gone, but it has enough underlying
utility (mostly constification) that I don't think we'd want to churn
the kernel hugely to make a change to struct pci_table and then have to
start detecting and fixing misuses.

James

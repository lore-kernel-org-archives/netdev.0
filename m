From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH v2 4/8] xen: Use the correctly the Xen memory terminologies
Date: Tue, 04 Aug 2015 19:16:45 -0400
Message-ID: <55C147DD.7000600@oracle.com>
References: <1438711972-18752-1-git-send-email-julien.grall@citrix.com>
 <1438711972-18752-5-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Jiri Slaby <jslaby@suse.com>, stefano.stabellini@eu.citrix.com,
 Russell King <linux@arm.linux.org.uk>, linux-scsi@vger.kernel.org,
 x86@kernel.org, Tomi Valkeinen <tomi.valkeinen@ti.com>,
 linux-input@vger.kernel.org,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 ian.campbell@citrix.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 "James E.J. Bottomley" <JBottomley@odin.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 linux-arm-kernel@lists.infradead.org, Juergen Gross <jgross@suse.com>,
 Wei Liu <wei.liu2@citrix.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-kernel@vger.kernel.org,
 David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org,
 =?UTF-8?B?Um9nZXIgUGF1IE1vbm7DqQ==?
To: Julien Grall <julien.grall@citrix.com>, xen-devel@lists.xenproject.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438711972-18752-5-git-send-email-julien.grall@citrix.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 08/04/2015 02:12 PM, Julien Grall wrote:
>   
>   /*
>    * We detect special mappings in one of two ways:
> @@ -217,9 +232,13 @@ static inline unsigned long bfn_to_local_pfn(unsigned long mfn)
>   
>   /* VIRT <-> MACHINE conversion */
>   #define virt_to_machine(v)	(phys_to_machine(XPADDR(__pa(v))))
> -#define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))
>   #define virt_to_mfn(v)		(pfn_to_mfn(virt_to_pfn(v)))
>   #define mfn_to_virt(m)		(__va(mfn_to_pfn(m) << PAGE_SHIFT))
> +#define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))

This looks like unnecessary change.


> diff --git a/drivers/video/fbdev/xen-fbfront.c b/drivers/video/fbdev/xen-fbfront.c
> index 09dc447..25e3cce 100644
> --- a/drivers/video/fbdev/xen-fbfront.c
> +++ b/drivers/video/fbdev/xen-fbfront.c
> @@ -539,7 +539,7 @@ static int xenfb_remove(struct xenbus_device *dev)
>   
>   static unsigned long vmalloc_to_mfn(void *address)
>   {
> -	return pfn_to_mfn(vmalloc_to_pfn(address));
> +	return pfn_to_gfn(vmalloc_to_pfn(address));
>   }

Are you sure? This will return vmalloc_to_pfn(address)).


-boris

From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH v2] iwlwifi: mvm: Fix a memory leak in an error handling
 path in 'iwl_mvm_sar_get_wgds_table()'
Date: Wed, 19 Jul 2017 09:59:52 +0300
Message-ID: <1500447592.22048.256.camel@coelho.fi>
References: <20170714100659.26369-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        linuxwifi@intel.com, kvalo@codeaurora.org, sara.sharon@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714100659.26369-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-07-14 at 12:06 +0200, Christophe JAILLET wrote:
> We should free 'wgds.pointer' here as done a few lines above in another
> error handling path.
> It was allocated within 'acpi_evaluate_object()'.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> v2: rebase after 7fe90e0e3d60 ("iwlwifi: mvm: refactor geo init")

Thanks, Christophe!

I've pushed this to our internal tree and it will eventually reach the
mainline via our normal process.


> Moreovern a comment in '/drivers/acpi/acpica/utalloc.c' states that:
> /* [...] Note: The caller should use acpi_os_free to free this
>  * buffer created via ACPI_ALLOCATE_BUFFER.
>  */
> 
> So, at the end of this function:
> 	out_free:
> 		kfree(wgds.pointer);
> should maybe be:
> 	out_free:
> 		acpi_os_free(wgds.pointer);
> 
> If correct, several places should be fixed accordingly.

Thanks for pointing out! I'm about to do some refactoring in this code
and I'll make sure I check the proper way to free the acpi buffer when
doing so.

--
Cheers,
Luca.

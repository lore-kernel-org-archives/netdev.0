From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/5] [RFC] Infiniband: connection
	abstraction
Date: Tue, 17 Jan 2006 15:38:38 -0800
Message-ID: <20060117153838.3dc2cd2e@dxpl.pdx.osdl.net>
References: <ORSMSX401FRaqbC8wSA0000003e@orsmsx401.amr.corp.intel.com>
	<ORSMSX401FRaqbC8wSA00000040@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
In-Reply-To: <ORSMSX401FRaqbC8wSA00000040@orsmsx401.amr.corp.intel.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Minor nits.

On Tue, 17 Jan 2006 15:24:37 -0800
"Sean Hefty" <sean.hefty@intel.com> wrote:

> The following patch extends matching connection requests to listens in the
> Infiniband CM to include private data.
> 
> Signed-off-by: Sean Hefty <sean.hefty@intel.com>
> 
> ---

> +static void cm_mask_compare_data(u8 *dst, u8 *src, u8 *mask)

static void cm_mask_compare_data(u8 *dst, const u8 *src, u8 *mask)

but I would rename it to cm_mask_copy since it doesn't really do a compare.


> +{
> +	int i;
> +
> +	for (i = 0; i < IB_CM_PRIVATE_DATA_COMPARE_SIZE; i++)
> +		dst[i] = src[i] & mask[i];
> +}
> +
> +static int cm_compare_data(struct ib_cm_private_data_compare *src_data,
> +			   struct ib_cm_private_data_compare *dst_data)

static int cm_compare_data(const struct ib_cm_private_data_compare *src,
		           cosnt struct ib_cm_private_data_compare *dst)
Your data type names are getting too long ^^^^^^^^^^^^^^^^^^^^^^^^


<flamebait>
Also should infiniband exports be EXPORT_SYMBOL_GPL, to make
it clear that binary drivers for this are not allowed??
</flamebait>

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger

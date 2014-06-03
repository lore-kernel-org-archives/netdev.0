From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next] hyper-v: make uuid_le const
Date: Tue, 3 Jun 2014 17:30:28 +0000
Message-ID: <04f86b9536044961bb702ecf554fc146@BL2PR03MB291.namprd03.prod.outlook.com>
References: <20140603083815.14688f8a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>, Haiyang Zhang
 <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140603083815.14688f8a@nehalam.linuxnetplumber.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Tuesday, June 3, 2014 8:38 AM
> To: KY Srinivasan; Haiyang Zhang
> Cc: devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: [PATCH net-next] hyper-v: make uuid_le const
> 
> The uuid structure could be managed as a const in several places.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Thanks Stephen.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

> 
> ---
> Patch against net-next because that is where most recent hyper-v related
> changes are.
> 
> 
> --- a/drivers/hv/channel_mgmt.c	2014-02-12 08:21:54.627887619 -0800
> +++ b/drivers/hv/channel_mgmt.c	2014-06-03 08:08:47.030901345 -0700
> @@ -365,7 +365,7 @@ static u32  next_vp;
>   * performance critical channels (IDE, SCSI and Network) will be uniformly
>   * distributed across all available CPUs.
>   */
> -static u32 get_vp_index(uuid_le *type_guid)
> +static u32 get_vp_index(const uuid_le *type_guid)
>  {
>  	u32 cur_cpu;
>  	int i;
> --- a/drivers/hv/vmbus_drv.c	2014-04-07 11:21:05.704486433 -0700
> +++ b/drivers/hv/vmbus_drv.c	2014-06-03 08:11:14.771854064 -0700
> @@ -435,7 +435,7 @@ static int vmbus_uevent(struct device *d
>  	return ret;
>  }
> 
> -static uuid_le null_guid;
> +static const uuid_le null_guid;
> 
>  static inline bool is_null_guid(const __u8 *guid)  { @@ -450,7 +450,7 @@
> static inline bool is_null_guid(const __
>   */
>  static const struct hv_vmbus_device_id *hv_vmbus_get_id(
>  					const struct hv_vmbus_device_id
> *id,
> -					__u8 *guid)
> +					const __u8 *guid)
>  {
>  	for (; !is_null_guid(id->guid); id++)
>  		if (!memcmp(&id->guid, guid, sizeof(uuid_le))) @@ -779,9
> +779,9 @@ EXPORT_SYMBOL_GPL(vmbus_driver_unregiste
>   * vmbus_device_create - Creates and registers a new child device
>   * on the vmbus.
>   */
> -struct hv_device *vmbus_device_create(uuid_le *type,
> -					    uuid_le *instance,
> -					    struct vmbus_channel *channel)
> +struct hv_device *vmbus_device_create(const uuid_le *type,
> +				      const uuid_le *instance,
> +				      struct vmbus_channel *channel)
>  {
>  	struct hv_device *child_device_obj;
> 
> --- a/drivers/hv/hyperv_vmbus.h	2014-04-07 11:21:05.704486433 -0700
> +++ b/drivers/hv/hyperv_vmbus.h	2014-06-03 08:27:12.618223800 -0700
> @@ -644,9 +644,9 @@ extern struct vmbus_connection vmbus_con
> 
>  /* General vmbus interface */
> 
> -struct hv_device *vmbus_device_create(uuid_le *type,
> -					 uuid_le *instance,
> -					 struct vmbus_channel *channel);
> +struct hv_device *vmbus_device_create(const uuid_le *type,
> +				      const uuid_le *instance,
> +				      struct vmbus_channel *channel);
> 
>  int vmbus_device_register(struct hv_device *child_device_obj);  void
> vmbus_device_unregister(struct hv_device *device_obj);

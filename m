From: Sylwester Nawrocki <s.nawrocki-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Thu, 04 Apr 2013 12:41:54 +0200
Message-ID: <515D58F2.7030404@samsung.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-2-git-send-email-kishon@ti.com> <515CA337.1010504@gmail.com>
 <515D462F.9050109@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org, cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org,
 eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
 broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 balbi-l0cyMroinI0@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-reply-to: <515D462F.9050109-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On 04/04/2013 11:21 AM, Kishon Vijay Abraham I wrote:
> On Thursday 04 April 2013 03:16 AM, Sylwester Nawrocki wrote:
>> On 04/03/2013 02:53 PM, Kishon Vijay Abraham I wrote:

>>> +4. Getting a reference to the PHY
>>> +
>>> +Before the controller can make use of the PHY, it has to get a
>>> reference to
>>> +it. This framework provides 6 APIs to get a reference to the PHY.
>>> +
>>> +struct phy *phy_get(struct device *dev, int index);
>>> +struct phy *devm_phy_get(struct device *dev, int index);
>>> +struct phy *of_phy_get(struct device *dev, const char *phandle, int
>>> index);
>>> +struct phy *devm_of_phy_get(struct device *dev, const char *phandle,
>>> int index);
>>
>> Why do we need separate functions for dt and non-dt ? Couldn't it be
>> handled
>> internally by the framework ? So the PHY users can use same calls for dt
>> and non-dt, like in case of e.g. the regulators API ?
> 
> yeah. Indeed it makes sense to do it that way.
>
>> Also signatures of some functions are different now:
>>
>> extern struct phy *phy_get(struct device *dev, int index);
>> extern struct phy *devm_phy_get(struct device *dev, int index);
>> extern struct phy *of_phy_get(struct device *dev, int index);
>> extern struct phy *devm_of_phy_get(struct device *dev, int index);
> 
> My bad :-(
> 
>> BTW, I think "extern" could be dropped, does it have any significance in
>> function declarations in header files ?
> 
> it shouldn't have any effect I guess. It's harmless nevertheless.

Yup.

>>> +struct phy *of_phy_get_byname(struct device *dev, const char *string);
>>> +struct phy *devm_of_phy_get_byname(struct device *dev, const char
>>> *string);

>>> --- /dev/null
>>> +++ b/drivers/phy/phy-core.c
>>> @@ -0,0 +1,616 @@
>>
>>> +static struct phy *of_phy_lookup(struct device_node *node)
>>> +{
>>> +    struct phy *phy;
>>> +    struct device *dev;
>>> +    struct class_dev_iter iter;
>>> +
>>> +    class_dev_iter_init(&iter, phy_class, NULL, NULL);
>>
>> There is currently nothing preventing a call to this function before
>> phy_class is initialized. It happened during my tests, and the nice
>> stack dump showed that it was the PHY user attempting to get the PHY
>> before the framework got initialized. So either phy_core_init should
>> be a subsys_initcall or we need a better protection against phy_class
>> being NULL or ERR_PTR in more places.
> 
> Whats the initcall used in your PHY user? Looks like more people prefer having

It happened in a regular platform driver probe() callback.

> module_init and any issue because of it should be fixed in PHY providers and
> PHY users.

OK. In fact this uncovered some issues in the MIPI DSI interface driver
(some unexpected interrupts). But this should just be fixed in those drivers
anyway. Now the DSI interface driver needs to wait for the PHY to be
registered and ready, so the initialization will likely be changed regardless
the framework initializes in module_init or earlier.

>>> +    while ((dev = class_dev_iter_next(&iter))) {
>>> +        phy = container_of(dev, struct phy, dev);
>>> +        if (node != phy->of_node)
>>> +            continue;
>>> +
>>> +        class_dev_iter_exit(&iter);
>>> +        return phy;
>>> +    }
>>> +
>>> +    class_dev_iter_exit(&iter);
>>> +    return ERR_PTR(-EPROBE_DEFER);
>>> +}
>>
>>> +/**
>>> + * of_phy_get() - lookup and obtain a reference to a phy by phandle
>>> + * @dev: device that requests this phy
>>> + * @index: the index of the phy
>>> + *
>>> + * Returns the phy associated with the given phandle value,
>>> + * after getting a refcount to it or -ENODEV if there is no such phy or
>>> + * -EPROBE_DEFER if there is a phandle to the phy, but the device is
>>> + * not yet loaded.
>>> + */
>>> +struct phy *of_phy_get(struct device *dev, int index)
>>> +{
>>> +    int ret;
>>> +    struct phy *phy = NULL;
>>> +    struct phy_bind *phy_map = NULL;
>>> +    struct of_phandle_args args;
>>> +    struct device_node *node;
>>> +
>>> +    if (!dev->of_node) {
>>> +        dev_dbg(dev, "device does not have a device node entry\n");
>>> +        return ERR_PTR(-EINVAL);
>>> +    }
>>> +
>>> +    ret = of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
>>> +        index,&args);
>>> +    if (ret) {
>>> +        dev_dbg(dev, "failed to get phy in %s node\n",
>>> +            dev->of_node->full_name);
>>> +        return ERR_PTR(-ENODEV);
>>> +    }
>>> +
>>> +    phy = of_phy_lookup(args.np);
>>> +    if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
>>> +        phy = ERR_PTR(-EPROBE_DEFER);
>>> +        goto err0;
>>> +    }
>>> +
>>> +    phy = phy->ops->of_xlate(phy,&args);
>>> +    if (IS_ERR(phy))
>>> +        goto err1;
>>> +
>>> +    phy_map = phy_bind(dev_name(dev), index, dev_name(&phy->dev));
>>> +    if (!IS_ERR(phy_map)) {
>>> +        phy_map->phy = phy;
>>> +        phy_map->auto_bind = true;
>>
>> Shouldn't it be done with the phy_bind_mutex held ? I guess an unlocked
>> version of the phy_bind functions is needed, so it can be used internally.
> 
> The locking is done inside phy_bind function. I'm not sure but I vaguely
> remember getting a dump stack (incorrect mutex ordering or something) when
> trying to have phy_bind_mutex here. I can check it again.

Yes, IIUC the locking needs to be reworked a bit so "phy_map" is not modified
without the mutex held.

>>> +    }
>>> +
>>> +    get_device(&phy->dev);
>>> +
>>> +err1:
>>> +    module_put(phy->ops->owner);
>>> +
>>> +err0:
>>> +    of_node_put(node);
>>> +
>>> +    return phy;
>>> +}
>>> +EXPORT_SYMBOL_GPL(of_phy_get);
>>
>>> +/**
>>> + * phy_create() - create a new phy
>>> + * @dev: device that is creating the new phy
>>> + * @label: label given to phy
>>> + * @of_node: device node of the phy
>>> + * @type: specifies the phy type
>>> + * @ops: function pointers for performing phy operations
>>> + * @priv: private data from phy driver
>>> + *
>>> + * Called to create a phy using phy framework.
>>> + */
>>> +struct phy *phy_create(struct device *dev, const char *label,
>>> +    struct device_node *of_node, int type, struct phy_ops *ops,
>>> +    void *priv)
>>> +{
>>> +    int ret;
>>> +    struct phy *phy;
>>> +    struct phy_bind *phy_bind;
>>> +    const char *devname = NULL;
>>> +
>>> +    if (!dev) {
>>> +        dev_err(dev, "no device provided for PHY\n");
>>> +        ret = -EINVAL;
>>> +        goto err0;
>>> +    }
>>> +
>>> +    if (!ops || !ops->of_xlate || !priv) {
>>> +        dev_err(dev, "no PHY ops/PHY data provided\n");
>>> +        ret = -EINVAL;
>>> +        goto err0;
>>> +    }
>>> +
>>> +    if (!phy_class)
>>> +        phy_core_init();
>>> +
>>> +    phy = kzalloc(sizeof(*phy), GFP_KERNEL);
>>> +    if (!phy) {
>>> +        ret = -ENOMEM;
>>> +        goto err0;
>>> +    }
>>> +
>>> +    devname = dev_name(dev);
>>
>> OK, a sort of serious issue here is that you can't call phy_create()
>> multiple times for same PHY provider device.
> 
> Ah.. right.

The other question I had was why we needed struct device object for each
PHY. And if it wouldn't be enough to have only struct device * in
struct phy, and the real device would be the PHY provider only. I might
be missing some reasons behind this decision though, as I have not been
following your work since the beginning.

>> device_add() further will fail as sysfs won't let you create multiple
>> objects with same name. So I would assume we need to add a new argument
>> to phy_create() or rename @type to e.g. @phy_id, which could be
>> concatenated with dev_name(dev) to create a unique name of the phy
>> device.
> 
> hmm.. ok
>>
>> And how is the PHY provider supposed to identify a PHY in its common PHY
>> ops, now when the struct phy port field is removed ? I have temporarily
>> (ab)used the type field in order to select proper registers within the
>> phy ops.
> 
> Can't it be handled in the PHY provider driver without using struct phy *?

You need to select registers/bit fields corresponding to a specific PHY,
since the phy ops are common. So we need to know exactly with which phy
we deal at the moment and I can't see any other option to figure out that
than by dereferencing struct phy *... ;)

> Moreover the PHY ops passes on the *phy to phy provider right? Not sure I

Yes, all you get in the ops is phy *. I wanted to avoid global variables
in the provider driver and be able to get to any provider private data
from phy * only.

If I use something like below for the PHY provider private data then from
struct phy * only I would need to get an index. This could be looked up by
iterating over phys[] array, but that seems an unnecessary complication.
Maybe there are better/easier ways to resolve it, without adding a new
field to struct phy.

struct phy_povider_priv {
	struct phy *phys[4];
	...
};

static in phy_power_on(struct phy *phy)
{
	struct phy_provider_priv *priv = dev_get_drvdata(&phy->dev);
	int phy_id = ...
	....
}
...
struct phy_ops ops = {
	.power_on = phy_power_on,
	...
};

> understand you here.
>
>>> +    device_initialize(&phy->dev);
>>> +
>>> +    phy->dev.class = phy_class;
>>> +    phy->dev.parent = dev;
>>> +    phy->label = label;
>>
>> What about duplicating the string here ? That would make the API a bit
>> more convenient and the callers wouldn't be required to keep all the
>> labels around.
> 
> you mean use dev_name? The device names are sometime more cryptic so preferred
> to have it like this.

No, I meant something like:

phy->label = kstrdup(label, GFP_KERNEL);

>>> +static int phy_core_init(void)
>>> +{
>>> +    if (phy_class)
>>> +        return 0;
>>> +
>>> +    phy_class = class_create(THIS_MODULE, "phy");
>>> +    if (IS_ERR(phy_class)) {
>>> +        pr_err("failed to create phy class -->  %ld\n",
>>> +            PTR_ERR(phy_class));
>>> +        return PTR_ERR(phy_class);
>>> +    }
>>> +
>>> +    phy_class->dev_release = phy_release;
>>> +    phy_class->dev_attrs = phy_dev_attrs;
>>> +
>>> +    return 0;
>>> +}
>>> +module_init(phy_core_init);
>>
>> Having this framework initialized before the PHY provider and consumer
>> drivers could save some unnecessary probe deferrals. I was wondering,
>> what is really an advantage of having it as module_init(), rather than
>> subsys_initcall() ?
> 
> I'm not sure of the exact reason but after the advent of EPROBE_DEFER, everyone
> recommends to use module_init only.

Ah...OK. We just need to ensure the resources are properly checked before
they are used then.

> Thanks for the detailed review.

Regards,
Sylwester

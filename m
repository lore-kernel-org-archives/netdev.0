From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH net-next v4 05/10] drivers: base: Add device_find_in_class_name()
Date: Wed, 18 Jan 2017 01:34:22 +0200
Message-ID: <CAHp75VfE8t+_2Yu1NYMErKopnCNwFakO6pyDRmqAU-ZsGuyvmg@mail.gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com> <20170117232152.1661-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170117232152.1661-6-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Add a helper function to lookup a device reference given a class name.
> This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
> make it more generic.


> +static int device_class_name_match(struct device *dev, void *class)

And why not const char *class?

> +{
> +       if (dev->class != NULL && !strcmp(dev->class->name, class))

if (dev->class && ...)

> +               return 1;
> +
> +       return 0;

Perhaps even one line:

return dev->class && ...;

> +}
> +
> +/**
> + * device_find_in_class_name - device iterator for locating a particular device
> + * within the specified class name
> + * @parent: parent struct device
> + * @class_name: Class name to match against
> + *
> + * This function returns 1 if the device (specified by @parent), or one of its child
> + * is in the class whose name is specified by @class_name. Returns 0 otherwise.
> + *
> + * NOTE: you will need to drop the reference with put_device() after use.
> + */
> +struct device *device_find_in_class_name(struct device *parent,
> +                                        char *class_name)

const char *class_name

> +{
> +       if (device_class_name_match(parent, class_name)) {
> +               get_device(parent);
> +               return parent;
> +       }
> +
> +       return device_find_child(parent, class_name, device_class_name_match);
> +}
> +EXPORT_SYMBOL_GPL(device_find_in_class_name);

> +extern struct device *device_find_in_class_name(struct device *parent,
> +                                               char *class_name);

Ditto.

-- 
With Best Regards,
Andy Shevchenko

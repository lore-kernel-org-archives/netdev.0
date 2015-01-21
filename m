From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: dsa: set parent of hwmon device
Date: Tue, 20 Jan 2015 18:48:03 -0800
Message-ID: <54BF1363.2080204@roeck-us.net>
References: <1421799212-2028-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421799212-2028-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/2015 04:13 PM, Vivien Didelot wrote:
> Set the dsa device as the parent of the hwmon device, in order to link
> the hwmon subsystem under the corresponding /sys/devices/platform/dsa.X/
> sysfs directory.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   net/dsa/dsa.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 3731714..363102a 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -347,7 +347,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>   		hname[j] = '\0';
>   		scnprintf(ds->hwmon_name, sizeof(ds->hwmon_name), "%s_dsa%d",
>   			  hname, index);
> -		ds->hwmon_dev = hwmon_device_register_with_groups(NULL,
> +		ds->hwmon_dev = hwmon_device_register_with_groups(parent,
>   					ds->hwmon_name, ds, dsa_hwmon_groups);
>   		if (IS_ERR(ds->hwmon_dev))
>   			ds->hwmon_dev = NULL;
>

I'll have to look into this again; not sure if this works because there is
no 1:1 relationship between dsa device and hwmon device (or switch chip).

Guenter

From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 05/10] drivers: base: Add device_find_class()
Date: Thu, 12 Jan 2017 14:50:39 -0800
Message-ID: <81f5965c-3484-92d9-5c04-94c5b73735d0@gmail.com>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
 <20170112034121.27697-6-f.fainelli@gmail.com>
 <20170112.162135.441956368122992032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, linux@armlinux.org.uk,
        vivien.didelot@savoirfairelinux.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112.162135.441956368122992032.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2017 01:21 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Wed, 11 Jan 2017 19:41:16 -0800
> 
>> Add a helper function to lookup a device reference given a class name.
>> This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
>> make it more generic.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/base/core.c    | 19 +++++++++++++++++++
>>  include/linux/device.h |  1 +
>>  2 files changed, 20 insertions(+)
>>
>> diff --git a/drivers/base/core.c b/drivers/base/core.c
>> index 020ea7f05520..3dd6047c10d8 100644
>> --- a/drivers/base/core.c
>> +++ b/drivers/base/core.c
>> @@ -2065,6 +2065,25 @@ struct device *device_find_child(struct device *parent, void *data,
>>  }
>>  EXPORT_SYMBOL_GPL(device_find_child);
>>  
>> +static int dev_is_class(struct device *dev, void *class)
> 
> I know you are just moving code, but this class argumnet is a string
> and thus should be "char *" or even "const char *".

Well, this is really so that we don't need to cast the arguments passed
to device_find_child(), which takes a void *data as well. If we made
that a const char *class, we'd get warnings that look like these:

drivers/base/core.c: In function 'device_find_class':
drivers/base/core.c:2083:2: warning: passing argument 2 of
'device_find_child' discards 'const' qualifier from pointer target type
[enabled by default]
  return device_find_child(parent, class, dev_is_class);
  ^
drivers/base/core.c:2050:16: note: expected 'void *' but argument is of
type 'const char *'
 struct device *device_find_child(struct device *parent, void *data,
                ^
drivers/base/core.c:2083:2: warning: passing argument 3 of
'device_find_child' from incompatible pointer type [enabled by default]
  return device_find_child(parent, class, dev_is_class);
  ^
drivers/base/core.c:2050:16: note: expected 'int (*)(struct device *,
void *)' but argument is of type 'int (*)(struct device *, const char *)'
 struct device *device_find_child(struct device *parent, void *data,
                ^

-- 
Florian

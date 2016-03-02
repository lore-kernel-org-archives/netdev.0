From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: Re: [PATCH] wan: lmc: Switch to using managed resources
Date: Wed, 2 Mar 2016 19:52:42 +0530
Message-ID: <CA+5yK5F0q=iKD_WAdXD6UWGLOYMt29Vq20Wh0w-Zf4sVFrTK0g@mail.gmail.com>
References: <20160227170416.GA1339@amitoj-Inspiron-3542>
	<20160301.172153.99852560992201587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160301.172153.99852560992201587.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 2, 2016 at 3:51 AM, David Miller <davem@davemloft.net> wrote:
> From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Date: Sat, 27 Feb 2016 22:34:16 +0530
>
>> @@ -835,23 +835,20 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>       err = pci_request_regions(pdev, "lmc");
>>       if (err) {
>>               printk(KERN_ERR "lmc: pci_request_region failed\n");
>> -             goto err_req_io;
>> +             return err;
>>       }
>>
>>       /*
>>        * Allocate our own device structure
>>        */
>> -     sc = kzalloc(sizeof(lmc_softc_t), GFP_KERNEL);
>> -     if (!sc) {
>> -             err = -ENOMEM;
>> -             goto err_kzalloc;
>
> You can't get rid of the error paths from here on out, because you still need to
> release the PCI regions obtained from pci_request_regions() above.
>
> To be quite honest, unless you are fixing real bugs, managed resource
> converstions are more likely to add bugs than do anything truly
> useful.
>
> I strongly consider you just drop this change.

Hi David,

I checked pcim_enable_device() before sending the patch, it has a call
to pcim_release() which does disabling of the PCI device and the
releasing of PCI regions obtained from pci_request_regions so there is
no need for pci_release_regions or pci_disable_device anymore.

Specifically, pcim_release contains the following code:

for (i = 0; i < DEVICE_COUNT_RESOURCE; i++)
  if (this->region_mask & (1 << i))
    pci_release_region(dev, i);

Also, commit id add243d5bc371eef66f81c9da4fd4b55a18dad23 is a similar
change that further made me believe that the change is a correct one.

However, if you think I am wrong somewhere and I understood things
incorrectly, please correct me.

Thanks,
Amitoj

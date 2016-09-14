From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH] net/mlx4_en: fix off by one in error handling
Date: Wed, 14 Sep 2016 17:49:49 +0300
Message-ID: <b2197c51-57a9-ab01-e940-9850a39484d6@gmail.com>
References: <alpine.LFD.2.20.1609141305360.1727@schleppi>
 <df5834ee-00c2-3f18-ae83-8bb06b6c675b@gmail.com>
 <alpine.LFD.2.20.1609141548390.11022@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.20.1609141548390.11022@schleppi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 14/09/2016 4:53 PM, Sebastian Ott wrote:
> Hello Tariq,
>
> On Wed, 14 Sep 2016, Tariq Toukan wrote:
>> On 14/09/2016 2:09 PM, Sebastian Ott wrote:
>>> If an error occurs in mlx4_init_eq_table the index used in the
>>> err_out_unmap label is one too big which results in a panic in
>>> mlx4_free_eq. This patch fixes the index in the error path.
>> You are right, but your change below does not cover all cases.
>> The full solution looks like this:
>>
>> @@ -1260,7 +1260,7 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
>>                                               eq);
>>                  }
>>                  if (err)
>> -                       goto err_out_unmap;
>> +                       goto err_out_unmap_excluded;
> In this case a call to mlx4_create_eq failed. Do you really have to call
> mlx4_free_eq for this index again?
We agree on this part, that's why here we should goto the _excluded_ label.
For all other parts, we should not exclude the eq in the highest index, 
and thus we goto the _non_excluded_ label.
>   As far as I understood this code
> mlx4_create_eq cleans up when it fails and thus there is no need for an
> additional mlx4_free_eq call.
>
> Regards,
> Sebastian
>
Regards,
Tariq

From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: [PATCH RFC net-next 3/4] net/mlx5: Separate between eswitch and
 MPFS l2 table logic
Date: Tue, 13 Jun 2017 14:18:03 -0400
Message-ID: <08f01bc7-6899-0587-c49c-209895e99424@fb.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
 <20170607234214.24723-4-saeedm@mellanox.com>
 <d205ed47-0275-ade7-1fdc-d82001b1dda5@fb.com>
 <CALzJLG-QeLp95diOuH+CFjX3rzChS4cne0ZKmHZg+1ZHFgCh1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37494 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752674AbdFMSSR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:18:17 -0400
In-Reply-To: <CALzJLG-QeLp95diOuH+CFjX3rzChS4cne0ZKmHZg+1ZHFgCh1w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2017 01:49 PM, Saeed Mahameed wrote:
> On Mon, Jun 12, 2017 at 8:52 PM, Jes Sorensen <jsorensen@fb.com> wrote:
>> On 06/07/2017 07:42 PM, Saeed Mahameed wrote:
>>>
>>> Multi-Physical Function Switch (MPFs) is required for when multi-PF
>>> configuration is enabled to allow passing user configured unicast MAC
>>> addresses to the requesting PF.
>>>
>>> Before this patch eswitch.c used to manage the HW MPFS l2 table,
>>> eswitch always enabled vport(0) (NIC PF) vport's contexts update on
>>> unicast
>>> mac address list changes, to populate the PF's MPFS L2 table accordingly,
>>> even if SRIOV was not enabled.
>>>
>>> In downstream patch we would like to allow compiling the driver without
>>> eswitch functionalities, for that we move MPFS l2 table logic out
>>> of eswitch.c into its own file, and provide Kconfig flag (MLX5_MPFS) to
>>> allow compiling out MPFS for those who don't want Multi-PF support
>>>
>>> NIC PF netdevice will now directly update MPFS l2 table via the new MPFS
>>> API. VF netdevice has no access to MPFS L2 table, so e-Switch will remain
>>> responsible of updating its PF MPFS l2 table on behalf of its VFs.
>>>
>>> Due to this change we also don't require enabling vport(0) (PF vport)
>>> unicast mac changes events anymore, for when SRIOV is not enabled.
>>> Which means eswitch is now activated only on SRIOV activation, and not
>>> required otherwise.
>>
>>
>>
>> On overall it looks good - one nit.
>>
>>> +static int alloc_l2table_index(struct mlx5_mpfs *l2table, u32 *ix)
>>> +{
>>> +       int err = 0;
>>> +
>>> +       *ix = find_first_zero_bit(l2table->bitmap, l2table->size);
>>> +       if (*ix >= l2table->size)
>>> +               err = -ENOSPC;
>>> +       else
>>> +               __set_bit(*ix, l2table->bitmap);
>>> +
>>> +       return err;
>>> +}
>>
>>
>> You pass in a pointer for ix but you don't modify it, why not just pass in
>> the value?.
>>
> 
> we do modify ix:
>     *ix = find_first_zero_bit(l2table->bitmap, l2table->size);
> 
> The idea is to find the next free index and return it to the caller

I clearly need new glasses :(

Jes

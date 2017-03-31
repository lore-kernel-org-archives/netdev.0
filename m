From: "Goel, Sameer" <sgoel-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [BUG] ethernet:mellanox:mlx5: Oops in health_recover
 get_nic_state(dev)
Date: Fri, 31 Mar 2017 13:55:42 -0600
Message-ID: <9d519df5-768a-ef17-07ca-5d16006d11e5@codeaurora.org>
References: <4a3539ba-6ce0-8ecf-1b1b-3c70cace6c2a@codeaurora.org>
 <CALzJLG-6pEXgukQdS0AEW40RZGeT_MNQmDV99GkgmC+wHbA4eA@mail.gmail.com>
 <d8f3cb19-cad9-c350-d26b-1c0ac6250933@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        rruigrok-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
To: Daniel Jurgens <danielj-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d8f3cb19-cad9-c350-d26b-1c0ac6250933-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 3/28/2017 7:25 AM, Daniel Jurgens wrote:
> On 3/28/2017 4:11 AM, Saeed Mahameed wrote:
>> On Tue, Mar 28, 2017 at 2:45 AM, Goel, Sameer <sgoel-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>>> Stack frame:
>>> [ 1744.418958] [<ffff00000328936c>] get_nic_state+0x24/0x40 [mlx5_core]
>>> [ 1744.425273] [<ffff0000032899c0>] health_recover+0x28/0x80 [mlx5_core]
>>> [ 1744.431496] [<ffff0000080e3280>] process_one_work+0x150/0x460
>>> [ 1744.437218] [<ffff0000080e35e0>] worker_thread+0x50/0x4b8
>>> [ 1744.442609] [<ffff0000080e9b98>] kthread+0xd8/0xf0
>>> [ 1744.447377] [<ffff000008083330>] ret_from_fork+0x10/0x20
>>>
>>> Summary:
>>> This issue was seen on QDF2400 system 30 mins after while running speccpu 2006. During the test a recoverable PCIe error was seen that gave the following log:
>>> [ 1673.170969] pcieport 0002:00:00.0: aer_status: 0x00004000, aer_mask: 0x00400000
>>> [ 1673.177961] pcieport 0002:00:00.0: aer_layer=Transaction Layer, aer_agent=Requester ID
>>> [ 1673.185832] pcieport 0002:00:00.0: aer_uncor_severity: 0x00462030
>>> [ 1675.536391] mlx5_core 0002:01:00.0: assert_var[0] 0xffffffff
>>> [ 1675.541093] mlx5_core 0002:01:00.0: assert_var[1] 0xffffffff
>>> [ 1675.546750] mlx5_core 0002:01:00.0: assert_var[2] 0xffffffff
>>> [ 1675.552377] mlx5_core 0002:01:00.0: assert_var[3] 0xffffffff
>>> [ 1675.558040] mlx5_core 0002:01:00.0: assert_var[4] 0xffffffff
>>> [ 1675.563661] mlx5_core 0002:01:00.0: assert_exit_ptr 0xffffffff
>>> [ 1675.569488] mlx5_core 0002:01:00.0: assert_callra 0xffffffff
>>> [ 1675.575120] mlx5_core 0002:01:00.0: fw_ver 15.4095.65535
>>> [ 1675.580426] mlx5_core 0002:01:00.0: hw_id 0xffffffff
>>> [ 1675.585363] mlx5_core 0002:01:00.0: irisc_index 255
>>> [ 1675.590242] mlx5_core 0002:01:00.0: synd 0xff: unrecognized error
>>> [ 1675.596301] mlx5_core 0002:01:00.0: ext_synd 0xffff
>>> [ 1675.601209] mlx5_core 0002:01:00.0: mlx5_enter_error_state:120:(pid 7205): start
>>> [ 1675.608613] mlx5_core 0002:01:00.0: mlx5_enter_error_state:127:(pid 7205): end
>>>
>>> After the above log we see the above stackframe and a page fault due to invalid dev pointer.
>>>
>>> So the the recovery work is queued and the timer is stopped. Somehow the workqueue is not cleared and when it runs the dev pointer is invalid.
>>>
>>> This issue was difficult to repro and was seen only once in multiple runs on a specific device.
>> Hi Sameer,
>>
>> Thanks for the report,
>> adding more relevant ppl
>>
>> Mohamad/Daniel Does the above ring a bell ?
>> can you check ?
>>
>> Thanks
>> Saeed.
> 
> Hi Sameer, Can you tell me if you have these 2 patches?
> 
> 5e44fca504705 ('net/mlx5: Only cancel recovery work when cleaning up device')
> 
> 689a248df83b ("net/mlx5: Cancel recovery work in remove flow")
> 
> 

Hi Daniel, 
 No I do not have these patches. I can pick up the cleanups from the mailing list. Are these patches
acked for 4.12?
Thanks,
Sameer
 
-- 
 Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc. Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

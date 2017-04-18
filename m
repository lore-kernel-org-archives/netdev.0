From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] net/mlx4: suppress 'may be used uninitialized' warning
Date: Tue, 18 Apr 2017 00:24:05 -0700
Message-ID: <xr93tw5m18mi.fsf@gthelen.mtv.corp.google.com>
References: <20170418062135.76698-1-gthelen@google.com> <20170418070219.GA14088@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Matan Barak <matanb@mellanox.com>,
        Ido Shamay <idos@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Amir Vadai <amirv@mellanox.com>,
        Roland Dreier <roland@purestorage.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170418070219.GA14088@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Leon Romanovsky <leon@kernel.org> wrote:

> [ Unknown signature status ]
> On Mon, Apr 17, 2017 at 11:21:35PM -0700, Greg Thelen wrote:
>> gcc 4.8.4 complains that mlx4_SW2HW_MPT_wrapper() uses an uninitialized
>> 'mpt' variable:
>>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_SW2HW_MPT_wrapper':
>>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2802:12: warning: 'mpt' may be used uninitialized in this function [-Wmaybe-uninitialized]
>>      mpt->mtt = mtt;
>>
>> I think this warning is a false complaint.  mpt is only used when
>> mr_res_start_move_to() return zero, and in all such cases it initializes
>> mpt.
>> But apparently gcc cannot see that.
>>
>> Initialize mpt to avoid the warning.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>
> It looks like other callers of mr_res_start_move_to() have the same
> "uninitialized" variable.
>
> Thanks

The above is the only mellanox warning I see.  So gcc is able to better
analyze the other callsites.

From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 02:29:15 +0900
Message-ID: <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com> <20171008.100013.2081721941420989813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>, abbotti@mev.co.uk,
        Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-rdma@vger.kernel.org, yishaih@mellanox.com,
        tariqt@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171008.100013.2081721941420989813.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-10-09 2:00 GMT+09:00 David Miller <davem@davemloft.net>:
> From: Masahiro Yamada <yamada.masahiro@socionext.com>
> Date: Mon,  9 Oct 2017 01:10:11 +0900
>
>> The headers
>>  - include/linux/mlx4/device.h
>>  - drivers/net/ethernet/mellanox/mlx4/mlx4.h
>> require the definition of struct radix_tree_root, but do not need to
>> know anything about other radix tree stuff.
>>
>> Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
>> reduce the header dependency.
>>
>> While we are here, let's add missing <linux/radix-tree.h> where
>> radix tree accessors are used.
>>
>> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
>
> Honestly this makes things more complicated.


The idea is simple; include necessary headers explicitly.

Putting everything into one common header
means most of C files are forced to parse unnecessary headers.



> The driver was trying to consolidate all of the header needs
> by including them all in one place, the main driver header.
>
> Now you're including headers in several different files.
>
> I really don't like the results of this change and would
> ask you to reconsider.
>
> Just add both radix-tree-root.h _and_ radix-tree.h to mlx4.h
> and leave the rest of the driver alone.


If you do not like this, you can just throw it away.

<linux/radix-tree.h> includes <linux/radix-tree-root.h>.
You do not need to include both.




-- 
Best Regards
Masahiro Yamada

From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Tue, 13 Dec 2016 11:34:33 +0530
Message-ID: <CA+sbYW3Z9qCDFPVwG1+tmQCSGgOfjt3Zf1ppQEMBPy=TgWqs-w@mail.gmail.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <CA+sbYW1ZEa5fndGkvN8OXr-orcUx4jaL73Di8zBJQX_uCdK=Ww@mail.gmail.com> <20161212170701.GA28387@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161212170701.GA28387-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2016 at 10:37 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> On Sat, Dec 10, 2016 at 11:06:58AM +0530, Selvin Xavier wrote:
>> On Fri, Dec 9, 2016 at 12:17 PM, Selvin Xavier
>> <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>> > I am preparing a git repository with these changes as per Jason's
>> > comment and will share the details later today.
>>
>> Please use bnxt_re branch in this git repository.
>>
>> https://github.com/Broadcom/linux-rdma-nxt.git
>
> Why are you using __packed in bnxt_re_uverbs_abi.h ? that doesn't seem
> necessary. It is a good idea to make sure all those structures are a
> multiple of 64 bits (add explicit reserved fields), and make sure you
> test 32 bit verbs as well.

Will take care in v3.

>
> Why are you using debugfs just to export counters? Isn't the core code
> counter framework good enough?

I agree that some of the counters exported by this patch set, tx and
rx bytes/pkts etc, can be exported
through the core counters. i will try adding  this support in v3, if
not, will post as a separate patch.
debugfs was introduced more for the future, in case any HW specific
data needs to be displayed.
As of now, it tracks only the count of resources( CQ/MR/QPs) active at
any given point. So its ok to
skip this patch from this series.

>
> Please try and avoid writing functions as defines (eg rdev_to_dev,
> to_bnxt_re, SQE_PG, RCFW_CMDQ_COOKIE, PTR_PG etc)
>
Sure, will take care in v3.

> There is something wrong with the tabs and spaces (see
> https://github.com/Broadcom/linux-rdma-nxt/blob/03e23b087f7e86ea28656273994e065827210ce5/drivers/infiniband/hw/bnxtre/bnxt_re_hsi.h)
>
> FWIW, I really dislike the column alignment style, it is so hard to
> maintain..
This file contains the Macro defines for the FW/HW structures and are
auto-generated. Some of these auto-generated defines are very long
which makes the lines greater than
80 characters. I will fix whatever possible and include in v3 set.

>
> Jason

Thanks,
Selvin
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

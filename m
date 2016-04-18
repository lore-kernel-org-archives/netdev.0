From: Sinan Kaya <okaya@codeaurora.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 13:47:59 -0400
Message-ID: <57151DCF.4070908@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
 <20160418143255.GA15203@infradead.org>
 <DB5PR05MB1848424EC9DC8D4150EADB03C56B0@DB5PR05MB1848.eurprd05.prod.outlook.com>
 <20160418151702.GA26565@infradead.org> <5714FB68.3020604@codeaurora.org>
 <20160418154058.GA4228@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"timur@codeaurora.org" <timur@codeaurora.org>,
	"cov@codeaurora.org" <cov@codeaurora.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418154058.GA4228@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/2016 11:40 AM, Christoph Hellwig wrote:
> On Mon, Apr 18, 2016 at 11:21:12AM -0400, Sinan Kaya wrote:
>> I was looking at the code. I don't see how removing virt_to_page + vmap 
>> would solve the issue.
>>
>> The code is trying to access the buffer space with direct.buf member
>> from the CPU side. This member would become NULL, when this code is 
>> removed and also in mlx4_en_map_buffer. 
>>
>> ...
>>
>> What am I missing?
> 
> As mentioned before you'll also need to enforce you hit the nbufs = 1
> case for these.  In fact most callers should simply switch to a plain
> dma_zalloc_coherent call without all these wrappers.  If we have a case
> where we really want multiple buffers that don't have to be contiguous
> (maybe the MTT case) I'd rather opencode that instead of building this
> confusing interface on top of it.
> 

I hit the first problem with CQE. The alloc routine is allocating pages
but CQE code is trying to do linear access with direct buf member. 


I see that this code implements page_list support. I'd like to do the same
thing for CQE. Let me know if I'm in the right path.

static struct mlx4_eqe *get_eqe(struct mlx4_eq *eq, u32 entry, u8 eqe_factor,
				u8 eqe_size)


-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project

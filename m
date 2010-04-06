From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH 1/3] A device for zero-copy based on KVM virtio-net.
Date: Tue, 6 Apr 2010 13:41:37 +0800
Message-ID: <97F6D3BD476C464182C1B7BABF0B0AF5C17B5BB9@shzsmsx502.ccr.corp.intel.com>
References: <20100308112849.GI7482@redhat.com>
 <1270114038-5048-1-git-send-email-xiaohui.xin@intel.com>
 <20100401110841.GE3323@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>,
	"yzhao81@gmail.com" <yzhao81@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100401110841.GE3323@redhat.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,
>> 
>>For the DOS issue, I'm not sure how much the limit get_user_pages()
>> can pin is reasonable, should we compute the bindwidth to make it?

>There's a ulimit for locked memory. Can we use this, decreasing
>the value for rlimit array? We can do this when backend is
>enabled and re-increment when backend is disabled.

I have tried it with rlim[RLIMIT_MEMLOCK].rlim_cur, but I found
the initial value for it is 0x10000, after right shift PAGE_SHIFT,
it's only 16 pages we can lock then, it seems too small, since the 
guest virito-net driver may submit a lot requests one time.


Thanks
Xiaohui


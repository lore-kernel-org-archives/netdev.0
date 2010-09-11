From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Sat, 11 Sep 2010 17:42:30 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D79280489AA0C@shsmsx502.ccr.corp.intel.com>
References: <1281086624-5765-5-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-6-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-7-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-8-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-9-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-10-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-11-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-12-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-13-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
 <20100906111126.GA15608@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79280489A9C9@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D79280489A9C9@shsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> +
>>> +	if (ctor->lock_pages + count > lock_limit && npages) {
>>> +		printk(KERN_INFO "exceed the locked memory rlimit.");
>>> +		return NULL;
>>> +	}
>>> +
>>> +	info = kmem_cache_zalloc(ext_page_info_cache, GFP_KERNEL);
>>
>>You seem to fill in all memory, why zalloc? this is data path ...
>
>Ok, Let me check this.

It's mainly for info->next and info->prev, these two fields will be used in hash functions.
But you are right, since most fields will be refilled. The new version includes the fix. 

Thanks
Xiaohui

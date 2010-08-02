From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
Date: Mon, 02 Aug 2010 19:11:41 +0300
Message-ID: <4C56EE3D.1050203@redhat.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>	 <1280442682.9058.15.camel@localhost.localdomain>	 <4C525CD2.5080604@redhat.com>	 <1280504771.9058.25.camel@localhost.localdomain>	 <4C552DC4.5000600@redhat.com> <1280764918.22830.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1280764918.22830.7.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  On 08/02/2010 07:01 PM, Shirley Ma wrote:
> Hello Avi,
>
> On Sun, 2010-08-01 at 11:18 +0300, Avi Kivity wrote:
>> I don't understand.  Under what conditions do you use
>> get_user_pages()
>> instead of get_user_pages_fast()?  Why?
> The code always calls get_user_pages_fast, however, the page will be
> unpinned in skb_free if the same page is not used again for a new
> buffer. The reason for unpin the page is we don't want to pin all of the
> guest kernel memory(memory over commit).

That is fine.

> So get_user_pages_fast will
> call slow path get_user_pages.

I don't understand this. gup_fast() only calls gup() if the page is 
swapped out or read-only.

> Your previous comment is suggesting to keep the page pinned for
> get_user_pages_fast fast path?
>

Right now I'm not sure I understand what's happening.

-- 
error compiling committee.c: too many arguments to function

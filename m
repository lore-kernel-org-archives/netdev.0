From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Mon, 02 Aug 2010 09:01:58 -0700
Message-ID: <1280764918.22830.7.camel@localhost.localdomain>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
	 <1280442682.9058.15.camel@localhost.localdomain>
	 <4C525CD2.5080604@redhat.com>
	 <1280504771.9058.25.camel@localhost.localdomain>
	 <4C552DC4.5000600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:34656 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942Ab0HBQCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 12:02:39 -0400
In-Reply-To: <4C552DC4.5000600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Avi,

On Sun, 2010-08-01 at 11:18 +0300, Avi Kivity wrote:
> I don't understand.  Under what conditions do you use
> get_user_pages() 
> instead of get_user_pages_fast()?  Why?

The code always calls get_user_pages_fast, however, the page will be
unpinned in skb_free if the same page is not used again for a new
buffer. The reason for unpin the page is we don't want to pin all of the
guest kernel memory(memory over commit). So get_user_pages_fast will
call slow path get_user_pages. 

Your previous comment is suggesting to keep the page pinned for
get_user_pages_fast fast path?

Thanks
Shirley


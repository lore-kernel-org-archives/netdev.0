From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
Date: Mon, 02 Aug 2010 19:32:24 +0300
Message-ID: <4C56F318.7030409@redhat.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>	 <1280442682.9058.15.camel@localhost.localdomain>	 <4C525CD2.5080604@redhat.com>	 <1280504771.9058.25.camel@localhost.localdomain>	 <4C552DC4.5000600@redhat.com>	 <1280764918.22830.7.camel@localhost.localdomain>	 <4C56EE3D.1050203@redhat.com> <1280766319.22830.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.hengli.com.au,
	jdike@linux.intel.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab0HBQck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 12:32:40 -0400
In-Reply-To: <1280766319.22830.24.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 08/02/2010 07:25 PM, Shirley Ma wrote:
> On Mon, 2010-08-02 at 19:11 +0300, Avi Kivity wrote:
>> I don't understand this. gup_fast() only calls gup() if the page is
>> swapped out or read-only.
> Oh, I used the page as read-only on xmit path. Should I use write
> instead?

No, for xmit getting the page as read only is fine.

I was inaccurate, gup_fast() performs as follows:

- if .write = 1, gup_fast() will be fast if the page is mapped and writeable
- if .write = 0, gup_fast() will be fast if the page is mapped

so, using .write = 0 for the xmit path will be faster in more cases than 
.write = 1.

When are you seeing gup_fast() fall back to gup()?  It should be at most 
once per page (when a guest starts up none of its pages are mapped, it 
faults them in on demand).

-- 
error compiling committee.c: too many arguments to function


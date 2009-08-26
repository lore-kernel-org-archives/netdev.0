From: Avi Kivity <avi@redhat.com>
Subject: Re: AlacrityVM benchmark numbers updated
Date: Wed, 26 Aug 2009 13:16:21 +0300
Message-ID: <4A950B75.5020409@redhat.com>
References: <4A948962.7090909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A948962.7090909@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/26/2009 04:01 AM, Gregory Haskins wrote:
> We are pleased to announce the availability of the latest networking
> benchmark numbers for AlacrityVM.  We've made several tweaks to the
> original v0.1 release to improve performance.  The most notable is a
> switch from get_user_pages to switch_mm+copy_[to/from]_user thanks to a
> review suggestion from Michael Tsirkin (as well as his patch to
> implement it).
>
> This change alone accounted for freeing up an additional 1.2Gbps, which
> is over 25% improvement from v0.1.  The previous numbers were 4560Gbps
> before the change, and 5708Gbps after (for 1500mtu over 10GE).  This
> moves us ever closer to the goal of native performance under virtualization.
>    

Interesting, it's good to see that copy_*_user() works so well.  Note 
that there's a possible optimization that goes in the opposite direction 
- keep using get_user_pages(), but use the dma engine API to perform the 
actual copy.  I expect that it will only be a win when using tso to 
transfer full pages.  Large pages may also help.

Copyless tx also wants get_user_pages().  It makes sense to check if 
switch_mm() + get_user_pages_fast() gives better performance than 
get_user_pages().

-- 
error compiling committee.c: too many arguments to function


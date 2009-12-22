From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 15:14:18 -0600
Message-ID: <4B3136AA.50204@codemonkey.ws>
References: <4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws> <4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws> <4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <20091222162110.GG10314@basil.fritz.box> <4B30F375.6050103@codemonkey.ws> <20091222173326.GH10314@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:41976 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbZLVVOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 16:14:24 -0500
In-Reply-To: <20091222173326.GH10314@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2009 11:33 AM, Andi Kleen wrote:
>> We're not talking about vaporware.  vhost-net exists.
>>      
> Is it as fast as the alacrityvm setup then e.g. for network traffic?
>
> Last I heard the first could do wirespeed 10Gbit/s on standard hardware.
>    

I'm very wary of any such claims.  As far as I know, no one has done an 
exhaustive study of vbus and published the results.  This is why it's so 
important to understand why the results are what they are when we see 
numbers posted.

For instance, check out 
http://www.redhat.com/f/pdf/summit/cwright_11_open_source_virt.pdf slide 32.

These benchmarks show KVM without vhost-net pretty closely pacing 
native.  With large message sizes, it's awfully close to line rate.

Comparatively speaking, consider 
http://developer.novell.com/wiki/index.php/AlacrityVM/Results

vbus here is pretty far off of native and virtio-net is ridiculus.

Why are the results so different?  Because benchmarking is fickle and 
networking performance is complicated.  No one benchmarking scenario is 
going to give you a very good picture overall.  It's also relatively 
easy to stack the cards in favor of one approach verses another.  The 
virtio-net setup probably made extensive use of pinning and other tricks 
to make things faster than a normal user would see them.  It ends up 
creating a perfect combination of batching which is pretty much just 
cooking the mitigation schemes to do extremely well for one benchmark.

This is why it's so important to look at vbus from the perspective of 
critically asking, what precisely makes it better than virtio.  A couple 
benchmarks on a single piece of hardware does not constitute an 
existence proof that it's better overall.

There are a ton of differences between virtio and vbus because vbus was 
written in a vacuum wrt virtio.  I'm not saying we are totally committed 
to virtio no matter what, but it should take a whole lot more than a 
couple netperf runs on a single piece of hardware for a single kind of 
driver to justify replacing it.

> Can vhost-net do the same thing?

I think the fundamentally question is, what makes vbus better than 
vhost-net?  vhost-net exists and is further along upstream than vbus is 
at the moment.  If that question cannot be answered with technical facts 
and numbers to back them up, then we're just arguing for the sake of 
arguing.

Regards,

Anthony Liguori

> -Andi
>    


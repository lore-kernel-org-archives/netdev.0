From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 09:12:19 -0600
Message-ID: <4B323353.8000607@codemonkey.ws>
References: <4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws> <4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <20091222162110.GG10314@basil.fritz.box> <4B30F375.6050103@codemonkey.ws> <20091222173326.GH10314@basil.fritz.box> <4B3136AA.50204@codemonkey.ws> <20091223000210.GA6518@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756203AbZLWPMd@vger.kernel.org>
In-Reply-To: <20091223000210.GA6518@sequoia.sous-sol.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2009 06:02 PM, Chris Wright wrote:
> * Anthony Liguori (anthony@codemonkey.ws) wrote:
>> The
>> virtio-net setup probably made extensive use of pinning and other tricks
>> to make things faster than a normal user would see them.  It ends up
>> creating a perfect combination of batching which is pretty much just
>> cooking the mitigation schemes to do extremely well for one benchmark.
>
> Just pinning, the rest is stock virtio features like mergeable rx buffers,
> GRO, GSO (tx mitigation is actually disabled).

Technically, tx mitigation isn't disabled.  The heuristic is changed 
such that instead of relying on a fixed timer, tx notification is 
disabled until you can switch to another thread and process packets.

The effect is that depending on time slice length and system load, you 
adaptively enable tx mitigation.  It's heavily dependent on the 
particulars of the system and the overall load.

For instance, this mitigation scheme looks great at high throughputs but 
looks very bad at mid-to-low throughputs compared to timer based 
mitigation (at least, when comparing CPU cost).

Regards,

Anthony Liguori

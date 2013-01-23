From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] tcp: add ability to set a timestamp offset (v2)
Date: Wed, 23 Jan 2013 13:27:00 -0500 (EST)
Message-ID: <20130123.132700.188651787864830558.davem@davemloft.net>
References: <1358953314-12979-1-git-send-email-avagin@openvz.org>
	<20130123162025.GA2147@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com, xemul@parallels.com,
	davej@redhat.com, mtk.manpages@gmail.com
To: kuznet@ms2.inr.ac.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130123162025.GA2147@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 23 Jan 2013 20:20:25 +0400

> Hello!
> 
> On Wed, Jan 23, 2013 at 07:01:52PM +0400, Andrey Vagin wrote:
>> -#define tcp_time_stamp         ((__u32)(jiffies))
>> +#define tcp_time_stamp(tp)     ((__u32)(jiffies) + tp->tsoffset)
> 
> This implies that you always have some tp in hands. AFAIK this is not true,
> so that I am puzzled how you were able to make something compilable with this definition.
> 
> At least in tcp_v4_send_ack() you obviously use some invalid tp, there is
> no socket in hands there. The thing which is called "sk" is dummy.
> 
> With container migration I used per-container offset. When you have no container,
> you have to do something a little bit smarter.

I'm starting to have almost no confidence in this change, and even the
basic conceptual idea behind it.

Please go back to the drawing board and really analyze this thing
completely rather than just bouncing broken patches to the list every
day.

Thanks.

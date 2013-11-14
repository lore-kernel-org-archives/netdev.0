From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] connector: improved unaligned access error fix
Date: Thu, 14 Nov 2013 16:22:32 -0500
Message-ID: <52853F18.4040605@tilera.com>
References: <201311141743.rAEHhuEV004998@farm-0012.internal.tilera.com> <20131114124549.7b5f3a7b@lembas.zaitcev.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Erik Jacobson <erikj@sgi.com>,
	Andrew Morton <akpm@osdl.org>,
	Matt Helsley <matthltc@us.ibm.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Pete Zaitcev <zaitcev@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131114124549.7b5f3a7b@lembas.zaitcev.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2013 2:45 PM, Pete Zaitcev wrote:
> On Thu, 14 Nov 2013 12:09:21 -0500
> Chris Metcalf <cmetcalf@tilera.com> wrote:
>
>> -	__u8 buffer[CN_PROC_MSG_SIZE];
>> +	__u8 buffer[CN_PROC_MSG_SIZE] __aligned(8);
>> -	msg = (struct cn_msg *)buffer;
>> +	msg = buffer_to_cn_msg(buffer);
>>  	ev = (struct proc_event *)msg->data;
>>  	memset(&ev->event_data, 0, sizeof(ev->event_data));
> Why is memset(buffer,0,CN_PROC_MSG_SIZE) not acceptable?

That would be fine from a correctness point of view; I'm happy
either way.  My patch nominally has better performance, for
what that's worth, since the memset() call is for a smaller
range (24 bytes instead of 60).  It also avoids the need for
put_unaligned(), which even on platforms that allow unaligned
stores can still be slower.

I can certainly do a v2 with the larger memset() instead if
that's the consensus.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

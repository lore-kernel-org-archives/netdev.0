From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compat: Ignore MSG_CMSG_COMPAT in
 compat_sys_{send,recv}msg
Date: Thu, 19 Feb 2015 16:15:08 -0500 (EST)
Message-ID: <20150219.161508.681345805038401073.davem@davemloft.net>
References: <1423744087-21317-1-git-send-email-catalin.marinas@arm.com>
	<20150212.084124.1966135201655814270.davem@davemloft.net>
	<20150212173218.GC25491@e104818-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Will.Deacon@arm.com, luto@amacapital.net
To: catalin.marinas@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150212173218.GC25491@e104818-lin.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 12 Feb 2015 17:32:18 +0000

> On Thu, Feb 12, 2015 at 04:41:24PM +0000, David Miller wrote:
>> Setting MSG_* bits that aren't supported by the protocol in any way
>> gives undefined semantics.  You may get an error, it may be silently
>> ignored, etc.
> 
> From the sendmsg(2) man page, if some bit in the flags is inappropriate
> for the socket type, it should return -EOPNOTSUPP. But I can't tell
> whether it refers only to bits which are defined (for other socket
> types) or just any bit. The test itself checks for -EOPNOTSUPP but it
> gets -EINVAL instead, hence the failure being reported.

Thanks for thinking about this a bit more.  Yes, -EINVAL is probably
not the thing we should return in this situation.

>> I'm not applying this, sorry.
> 
> What I'm after is consistency between the native 32-bit kernel and the
> compat layer on 64-bit. On the former, bit 31 is silently ignored, on
> the latter it reports -EINVAL.
> 
> We could as well do something like below but we end up with unnecessary
> flags check on 32-bit. The question is whether such change would be
> considered a 32-bit user ABI breakage.

Ok, after some further consideration I like your original patch.

If 32-bit ignores the value, 64-bit should too.  So just mask it out.

Please resubmit your original patch, I'll apply it, thanks!

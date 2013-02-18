From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Mon, 18 Feb 2013 09:54:31 +0100
Message-ID: <5121EC47.2080402@250bpm.com>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com> <20130214145430.04f8750c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Eric Wong <normalperson@yhbt.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130214145430.04f8750c.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/02/13 23:54, Andrew Morton wrote:

>> +/*  On x86-64 keep the same binary layout as on i386. */
>> +#ifdef __x86_64__
>> +#define EVENTFD_MASK_PACKED __packed
>> +#else
>> +#define EVENTFD_MASK_PACKED
>> +#endif
>> +
>> +struct eventfd_mask {
>> +	__u32 events;
>> +	__u64 data;
>> +} EVENTFD_MASK_PACKED;
>
> The x86-64 specific thing is ugly.  I can find no explanation of why it
> was done, but it should go away.  You could make `events' a u64, or
> swap the order of the two fields and make the struct __packed on all
> architectures.
>
> Given that the size of the types is fixed, I see no compat issues here.

I've just copied how the definition is done for epoll_event. The comment 
there goes like this:

/*
  * On x86-64 make the 64bit structure have the same alignment as the
  * 32bit structure. This makes 32bit emulation easier.
  *
  * UML/x86_64 needs the same packing as x86_64
  */

If you still think I should remove the #ifdef, I am happy to do so.

Martin

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/13] sctp: use get_unused_fd_flags(0) instead of
 get_unused_fd()
Date: Tue, 02 Jul 2013 16:14:28 -0700 (PDT)
Message-ID: <20130702.161428.1703028286206350504.davem@davemloft.net>
References: <cover.1372777600.git.ydroneaud@opteya.com>
	<6d4271e2e0b05ae2728cba1d890e77cac50cf8f0.1372777600.git.ydroneaud@opteya.com>
	<51D312E8.6090702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ydroneaud@opteya.com, linux-kernel@vger.kernel.org,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D312E8.6090702@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 02 Jul 2013 13:50:32 -0400

> On 07/02/2013 12:39 PM, Yann Droneaud wrote:
>> Macro get_unused_fd() is used to allocate a file descriptor with
>> default flags. Those default flags (0) can be "unsafe":
>> O_CLOEXEC must be used by default to not leak file descriptor
>> across exec().
>>
>> Instead of macro get_unused_fd(), functions anon_inode_getfd()
>> or get_unused_fd_flags() should be used with flags given by userspace.
>> If not possible, flags should be set to O_CLOEXEC to provide userspace
>> with a default safe behavor.
>>
>> In a further patch, get_unused_fd() will be removed so that
>> new code start using anon_inode_getfd() or get_unused_fd_flags()
>> with correct flags.
>>
>> This patch replaces calls to get_unused_fd() with equivalent call to
>> get_unused_fd_flags(0) to preserve current behavor for existing code.
>>
>> The hard coded flag value (0) should be reviewed on a per-subsystem
>> basis,
>> and, if possible, set to O_CLOEXEC.
>>
>> Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied to net-next, thanks.

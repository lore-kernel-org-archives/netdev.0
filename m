From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] netlink: don't copy over empty attribute data
Date: Tue, 21 Oct 2014 22:19:36 -0400
Message-ID: <54471438.1040907@oracle.com>
References: <1413924669-26732-1-git-send-email-sasha.levin@oracle.com> <20141021.213908.1088381802543942481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: a.ryabinin@samsung.com, pablo@netfilter.org, mschmidt@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141021.213908.1088381802543942481.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2014 09:39 PM, David Miller wrote:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Tue, 21 Oct 2014 16:51:09 -0400
> 
>> > netlink uses empty data to seperate different levels. However, we still
>> > try to copy that data from a NULL ptr using memcpy, which is an undefined
>> > behaviour.
>> > 
>> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> This isn't a POSIX C library, this it the Linux kernel, and as such
> we can make sure none of our memcpy() implementations try to access
> any bytes if the given length is NULL.

We can make *our* implementations work around that undefined behaviour if we
want, but right now our implementations is to call GCC's builtin memcpy(),
which follows the standards and doesn't allow you to call it with NULL 'from'
ptr.

The fact that it doesn't die and behaves properly is just "luck".


Thanks,
Sasha

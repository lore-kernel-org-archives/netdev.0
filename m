From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Wed, 28 Jan 2004 11:09:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128110945.662a4d6a.davem@redhat.com>
References: <OF27A95A54.FAB6CE99-ON88256E24.000E2136@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF27A95A54.FAB6CE99-ON88256E24.000E2136@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Jan 2004 18:45:18 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

>             / * Overflow, sync and re-read, the next read is guaranteed to
> be greater
>              * than res1.
>              */
>             synchronize_kernel();
>             res2 = *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) + sizeof
> (__u64) * nr)));

I don't understand how your scheme can work.

We're trying to detect if the upper 32-bit half of the 64-bit value
belongs with the lower-half.  We can overflow the lower-half TWICE
in the res1=...res2=... sequence you do, and this res2 reread in the if
branch can overflow itself again, combining a lower and upper half which
do not belong to each other.

This is not so trivial to fix, see? :)

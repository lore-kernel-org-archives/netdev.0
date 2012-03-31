From: David Miller <davem@davemloft.net>
Subject: Re: sendmmsg: put_user vs __put_user
Date: Fri, 30 Mar 2012 20:51:20 -0400 (EDT)
Message-ID: <20120330.205120.2221145622131588797.davem@davemloft.net>
References: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: drepper@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@gmail.com>
Date: Fri, 30 Mar 2012 09:36:11 -0400

> Shouldn't the compat code in the sendmmsg implementation use the same
> code as the normal code?  In which case you probably want something
> like this:

Compat processes are not able to generate virtual addresses anywhere
near the range where the kernel resides, so the address range
verification done by put_user() is completely superfluous and
therefore not necessary.  The normal exception handling done by the
access is completely sufficient.

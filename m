From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Fri, 29 Oct 2004 20:37:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030013700.GA21540@lists.us.dell.com>
References: <20041029215134.GA15414@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041029215134.GA15414@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 04:51:34PM -0500, Matt Domsch wrote:
> If dev->dev_addr is zero, then the memcpy() never takes place, and the
> same data that was in the caller's buffer is still in the caller's
> buffer on successful return.  The caller can't know that the data in
> its buffer isn't the right answer.  So, if dev->dev_addr == 0,
> clear the buffer before returning success.

Some additional detail I forgot to include.

s/dev_addr/addr_len in the comments above, that's the field we care
about being non-zero.

This directly affects ppp devices, as those have dev->addr_len == 0.
This was seen because net-snmp reports the MAC address of devices in
the system, and for ppp devices was reporting an address of 0x00FFFFFF
because that was the data in the buffer prior to calling ioctl().
This patch causes the 2.6 behaviour to match that of the 2.4 kernel
which has a fixed length MAX_ADDR_LEN instead of a variable addr_len
and always copies MAX_ADDR_LEN bytes.

Thanks to Jordan Hargrave for root cause analysis and suggesting the
fix.

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
